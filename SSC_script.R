# Statistical Stopping Criteria
# Author: Tyler Wu

# Package for calculating p-values from Callaghan & Müller-Hansen (2020)
library(buscarR)
library(readxl)
library(tidyverse)

# Create proxy dataset
ds <- data.frame(relevant = rep(NA, 3736),
                 seen = rep(0, 3736))

# Function for finding all p-values for a given simulation
find_pval <- function(dataset, ttd_relevant) {
  df <- dataset
  pvals <- c()
  
  for(i in 1:(nrow(df) - 1)) {
    df$seen[i] <- 1
    
    if(i %in% ttd_relevant) {
      df$relevant[i] <- 1
    } else {
      df$relevant[i] <- 0
    }
    
    p <- calculate_h0(df)
    pvals <- c(pvals, p)
  }
  return(pvals)
}

# Returns first index of a significant pval, i.e. stopping point
pval_index <- function(pvals, threshold) {
  significant <- which(pvals <= threshold)
  return(significant[1])
}

# Finds total number of relevant records
relevant_rec <- function(ttd_vec, cutoff) {
  return(sum(ttd < cutoff))
}

# Import TTD Data
ttd_data <- read_xlsx("TTD_data.xlsx")

# Find stopping points for each simulation
stop_points_90 <- c()
stop_points_95 <- c()
stop_points_99 <- c()

recall_90 <- c()
recall_95 <- c()
recall_99 <- c()

for(i in 1:length(ttd_data)) {
  # Extract ttd data for each simulation
  ttd <- ttd_data[[i]]
  ttd <- ttd[!is.na(ttd)]
  
  # Find pvals for each simulation
  pval_vec <- find_pval(dataset = ds, ttd_relevant = ttd)
  
  # Find stopping points for alpha = 0.05 and alpha = 0.01
  threshold_90 <- pval_index(pvals = pval_vec, threshold = 0.1)
  stop_points_90 <- c(stop_points_90, threshold_90)
  
  threshold_95 <- pval_index(pvals = pval_vec, threshold = 0.05)
  stop_points_95 <- c(stop_points_95, threshold_95)
  
  threshold_99 <- pval_index(pvals = pval_vec, threshold = 0.01)
  stop_points_99 <- c(stop_points_99, threshold_99)
  
  # Find recall
  recall_90 <- c(recall_90, relevant_rec(ttd_vec = ttd, 
                                        cutoff <- stop_points_90[i]))
  recall_95 <- c(recall_95, relevant_rec(ttd_vec = ttd, 
                                        cutoff <- stop_points_95[i]))
  recall_99 <- c(recall_99, relevant_rec(ttd_vec = ttd, 
                                        cutoff <- stop_points_99[i]))
}

recall_90 <- recall_90 / 213
recall_95 <- recall_95 / 213
recall_99 <- recall_99 / 213

prop_rv_90 <- stop_points_90 / 3736
prop_rv_95 <- stop_points_95 / 3736
prop_rv_99 <- stop_points_99 / 3736

# Tables of Results
SSC_Results <- data.frame(Model = rep(c("TF-IDF/Naive Bayes",
                                        "Doc2Vec/Logistic Regression",
                                        "TF-IDF/Logistic Regression"), 
                                         30),
                          recall_90,
                          recall_95,
                          recall_99,
                          prop_rv_90,
                          prop_rv_95,
                          prop_rv_99)

# Reformatting Table
SSC_95 <- data.frame(Model = SSC_Results$Model,
                     recall = SSC_Results$recall_95,
                     prop_rv = SSC_Results$prop_rv_95)

Model1_Results <- SSC_95 %>% filter(Model == "TF-IDF/Naive Bayes")
Model2_Results <- SSC_95 %>% filter(Model == "Doc2Vec/Logistic Regression")
Model3_Results <- SSC_95 %>% filter(Model == "TF-IDF/Logistic Regression")

#################
# Creating Graph
SSC_table <- SSC_95
SSC_table$Model <- factor(SSC_table$Model, levels = c("TF-IDF/Naive Bayes", 
                                                    "Doc2Vec/Logistic Regression",
                                                    "TF-IDF/Logistic Regression"))
base1 <- ggplot(SSC_table, aes(`prop_rv`, recall)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  scale_x_continuous(name = "Proportion of Total Records Viewed", limits = c(0, 1.0)) +
  scale_y_continuous(name = "Recall", limits = c(0.95, 1.0)) +
  theme(plot.title=element_text(size=12), 
        legend.text=element_text(size=12), 
        axis.text=element_text(size=7),
        legend.title=element_text(size=14))
uds_facet1 <- base1 + facet_grid(. ~ Model) + theme(strip.text = element_text(size = 8))
uds_facet1
