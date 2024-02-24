
pacman::p_load(dplyr,readxl,sna)

alignments = read_excel("./Data Files/aggregate_alignments.xlsx")
grouped_state_year = read_excel("./Data Files/grouped_state_year.xlsx")
edges = read_csv("./Data Files/dhb2015apsr-networks.csv")

#keep only 2008 edges and drop colorado (replicating authors)
edges  = edges %>% filter(year == 2008, state_01 != "CO", state_02 != "CO")

# keep only US states
ustates =  sort(unique(c(alignments$left_state,alignments$right_state)))
ustates <- ustates[which(!is.element(ustates,c("pr", "dc")))]

## keep alignmetns only for states
alignments = aggregate_alignments %>% 
  
  filter(left_state != 'dc',
         right_state != 'dc')%>%
  
  filter(left_state != 'pr',
         right_state != 'pr')

#####create matrices##########

### create diffusion matrix

diff_amat <- matrix(0,length(ustates),length(ustates))
# assure the nodes are consistent
rownames(diff_amat) <- colnames(diff_amat) <- ustates

# add in ties
diff_amat[cbind(tolower(edges$state_01), 
                tolower(edges$state_02))] <- edges$src_35_300

# make sure it is undirected
diff_amat <- diff_amat + t(diff_amat) 
diff_amat <- 1*(diff_amat>0)

##### create alignment score matrix #####

align_amat <- matrix(0,length(ustates),length(ustates))
rownames(align_amat) <- colnames(align_amat) <- ustates

align_amat[cbind(tolower(alignments$left_state),tolower(alignments$right_state))] <- alignments$adjusted_alignment_score_sum
# make sure it is undirected
align_amat <- align_amat + t(align_amat)

##### create coverage matrix #####

yrs_covered <- numeric(length(ustates))
coverage <- table(subset(grouped_state_year$state,!is.element(grouped_state_year$state,c("pr","dc"))))
yrs_covered[match(names(coverage),ustates)] <- coverage
coverage_mat <- log(cbind(yrs_covered)%*%t(yrs_covered))


# zero out diagonals (i.e., not modeling loops)
diag(diff_amat) <- 0
diag(align_amat) <- 0
diag(coverage_mat) <- 0


set.seed(5)

### regressing with identity link ######
bivariate_qap <- netlm(align_amat,list(diff_amat,coverage_mat),mode="graph",reps=1000)
results <- cbind(bivariate_qap$coefficients / sd(alignments$adjusted_alignment_score_sum),
                 bivariate_qap$pgreqabs)
rownames(results) <- c("Intercept","Diffusion Tie","Coverage")
colnames(results) <- c("Coefficient","p-value")

### regressing with log link #########

bivariate_qap_log <- netlm(log(align_amat),list(diff_amat,coverage_mat),mode="graph",reps=1000)
results_log <- cbind(bivariate_qap_log$coefficients / sd(log(alignments$adjusted_alignment_score_sum)),
                     bivariate_qap_log$pgreqabs)
rownames(results_log) <- c("Intercept","Diffusion Tie","Coverage")
colnames(results_log) <- c("Coefficient","p-value")