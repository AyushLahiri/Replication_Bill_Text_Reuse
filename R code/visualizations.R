pacman::p_load(dplyr,ggplot2,readxl)

### visualize state and yearwise counts 

counts = read_csv("./Data Files/counts.csv")
sample = read_excel("./Data Files/sampled.xlsx")

bill_meta = read_excel("./Data Files/joined_metadata.xlsx")
bill_meta = bill_meta %>% filter(adjusted_alignment_score > 0)


ggplot(counts, aes(x = year, y = state, size = count)) +
  geom_point(alpha = 0.7, shape = 21, fill = '#E69F00') +  
  scale_size_continuous(range = c(1, 5), 
                        breaks = c(500, 10000, 15000), 
                        labels = c("500", "10000", "15000")) + 
  labs(x = "Year", y = "State", size = "Count", title = "State and Year-wise Bill Counts") +
  theme_minimal() +
  theme(legend.position = "right")



### Visualize CDF of sampled alignments

sample <- sample %>%
  group_by(adjusted_alignment_score) %>% summarise(num = n()) %>% 
  arrange(adjusted_alignment_score) %>% 
  mutate(cum_frequency=cumsum(num),
         rel_cumfreq = cum_frequency/sum(num))

## get counts of alignment score ranges for legend
count <- sample %>%
  mutate(category = ifelse(score >= 0 & score <= 31, 1,
                           ifelse(score >= 31 & score <= 60, 2,
                                  ifelse(score >= 61 & score <= 2000, 3, NA))))

# Now, group by the new category and count the occurrences
count_df <- count %>%
  group_by(category) %>%
  summarise(count = n())


##plot CDF
p <- ggplot(sample, aes(x = adjusted_alignment_score, y = rel_cumfreq)) +
  geom_line() + scale_y_log10()# Draw the CDF line
theme_minimal()

x_start1 <- 0
x_end1   <- 30
x_start2 <- 31
x_end2   <- 60
x_start3 <- 61
x_end3   <- 1291
#Subset the data and add the coordinates to make it shade to y = 0
shade1 <- rbind(c(x_start1,0), subset(sample, adjusted_alignment_score >= 
                                        x_start1 & adjusted_alignment_score <= x_end1), c(x_end1, 0))
shade2 <- rbind(c(x_start2,0), subset(sample, adjusted_alignment_score >= 
                                        x_start2 & adjusted_alignment_score <= x_end2), c(x_end2, 0))
shade3 <- rbind(c(x_start3,0), subset(sample, adjusted_alignment_score >= 
                                        x_start3 & adjusted_alignment_score <= x_end3), c(x_end3, 0))

# add shading to cdf curve
p <- p + geom_polygon(data = shade1, aes(adjusted_alignment_score, rel_cumfreq, fill = "1364"), alpha = 0.5) +
  geom_polygon(data = shade2, aes(adjusted_alignment_score, rel_cumfreq, fill = "68"), alpha = 0.5) +
  geom_polygon(data = shade3, aes(adjusted_alignment_score, rel_cumfreq, fill = "22"), alpha = 0.5) +
  scale_fill_manual("Number of Documents", values = c("1364" = "grey", 
                                                      "68" = "#F0E442",
                                                      "22" = "#56B4E9"))+labs(y = "Proportion <Score", x = "Alignment Score")
p


### plot distribution of ideology vs alignment score. No point in using hexbin for such a small sample
m = ggplot(bill_meta, aes(x = dist, y = adjusted_alignment_score)) +
  geom_point(alpha = 0.5, size = 3, color = '#E69F00') +  
  xlab("Ideological Distance") +scale_y_log10()+
  ylab("Log Alignment Score") +
  theme_minimal()
m

m = m + scale_y_log10() + ylab("Log Alignment Score")
m
