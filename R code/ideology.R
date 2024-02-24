pacman::p_load(dplyr,quantreg,ggplot2)

### Read fully matched alignments data
bill_meta = read_excel("./Data Files/joined_metadata.xlsx")


bill_meta = bill_meta %>% filter(adjusted_alignment_score > 0)

##create regression function
quant_reg <- function(q, dat) {
  return(rq(adjusted_alignment_score ~ dist, data = dat, tau = q, method = "pfn"))
}

# Perform quantile regression for specified quantiles
quantiles <- c(seq(0.5, 0.9, by = 0.2), seq(0.91, 0.97, by = 0.03))
models <- lapply(quantiles, quant_reg, dat = bill_meta)
models_coefs <- lapply(models, coef)

B <- 50  # Boostrao 50 samples.
bootstrap_results <- vector(mode = "list", length = B)
clusters <- unique(bill_meta$left_id)

# Bootstrap loop
for(i in 1:B) {
  # Sample clusters with replacement and create the bootstrap dataset
  sampled_clusters <- sample(clusters, length(clusters), replace = TRUE)
  bootstrap_data <- bill_meta[bill_meta$left_id %in% sampled_clusters, ]
  
  # Fit quantile regression models to the bootstrap sample
  bootstrap_models <- lapply(quantiles, quant_reg, dat = bootstrap_data)
  bootstrap_coefs <- lapply(bootstrap_models, coef)
  
  # Store the coefficients from this bootstrap iteration
  bootstrap_results[[i]] <- bootstrap_coefs
  cat(paste0("Completed bootstrap iteration ", i, "\n"))
}

original_coefs <- sapply(models_coefs, function(x) x['dist'])

# Initialize a matrix to store the bootstrap coefficients for easier manipulation
num_quantiles <- length(quantiles)
num_coefs <- length(models_coefs[[1]])  


# Each row is a quantile, each column is a bootstrap sample
bootstrap_coefs_matrix <- matrix(NA, nrow = num_quantiles, ncol = B)
for (b in 1:B) {
  for (q in 1:num_quantiles) {
    bootstrap_coefs_matrix[q, b] <- bootstrap_results[[b]][[q]]['dist']
  }
}

# Calculate confidence intervals for each quantile
conf_ints <- apply(bootstrap_coefs_matrix, 1, function(x) {
  c(lower = quantile(x, probs = 0.025), upper = quantile(x, probs = 0.975))
})

# Combine results into a dataframe
results_df <- data.frame(
  Quantile = quantiles,
  Original_Coef = original_coefs,
  Lower_CI = conf_ints[1, ],
  Upper_CI = conf_ints[2, ]
)


## 
results_df$Quantile <- factor(results_df$Quantile, levels = unique(results_df$Quantile))

# Create the plot
ggplot(results_df, aes(x = Original_Coef, y = Quantile)) + 
  geom_point() +  # Add points for the original coefficients
  geom_errorbarh(aes(xmin = Lower_CI, xmax = Upper_CI), height = 0.2) +  # Add horizontal error bars for CIs
  labs(x = "Coefficient", y = "Quantile", title = "Quantile Regression Coefficients with Confidence Intervals") + 
  theme_minimal() +
  xlim(-1, 25)

  