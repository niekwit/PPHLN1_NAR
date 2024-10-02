library(tidyverse)
library(cowplot)

### TE analysis
levels <- c("Transposon", "ERV", "Alu",
            "SINE", "LINE1", "LINE")
data_fl <- read.table("gat/gat_formatted_TE_PPHLN1_FL.txt", header = TRUE) %>%
  mutate(sample = "PPHLN1 FL")
data_fl$annotation <- factor(data_fl$annotation, levels = levels)
data_127 <- read.table("gat/gat_formatted_TE_PPHLN1_1-127.txt", header = TRUE) %>%
  mutate(sample = "PPHLN1 1-127")
data_127$annotation <- factor(data_127$annotation, levels = levels)
data <- rbind(data_fl, data_127)
data$sample <- factor(data$sample, levels = c("PPHLN1 FL", "PPHLN1 1-127"))

plot_single <- function(data, title, max) {
  p <- ggplot(data, aes(x = fold, 
                        y = annotation, 
                        fill = qvalue < 0.05)) +
    geom_col(colour = "black") +
    theme_cowplot(18) +
    labs(x = "Fold change (observed/expected)", 
         y = NULL,
         title = title) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    scale_x_continuous(expand= c(0, 0), limits = c(0, max)) +
    scale_fill_manual(values = c("TRUE" = "dodgerblue3", "FALSE" = "grey50"))
  ggsave(paste0("gat/gat_bargraph_TE_", gsub(" ", "_", title), ".pdf"), 
         p, 
         width = 8, 
         height = 4)
}

plot_single(data_fl, "PPHLN1 FL binding", 5)
plot_single(data_127, "PPHLN1 1-127 binding", 5)

# Plot both together
p <- ggplot(data,aes(x = fold,
                     y = annotation,
                     fill = qvalue < 0.05)) +
  geom_col(position = "dodge",
           colour = "black") +
  facet_wrap(~sample, ncol = 1) +
  theme_cowplot(18) +
  labs(x = "Fold change (observed/expected)", 
       y = NULL,
       title = "PPHLN1 binding") +
  geom_vline(xintercept = 1, 
             linetype = "dashed") +
  scale_x_continuous(expand= c(0, 0), 
                     limits = c(0, 5)) +
  scale_fill_manual(values = c("TRUE" = "dodgerblue3", "FALSE" = "grey50"))

ggsave("gat/gat_bargraph_te_all.pdf", 
       p, 
       width = 8, 
       height = 6)

## MPP8 TASOR sites
data <- read.table("gat/gat_formatted_MPP8_TASOR_PPHLN1_FL.txt", header = TRUE) 
data$annotation <- factor(data$annotation, levels = c("TASOR", "MPP8"))

plot_single <- function(df, title, max) {
  p <- ggplot(df, aes(x = fold,
                      y = annotation,
                      fill = qvalue < 0.05)) +
    geom_col(colour = "black") +
    theme_cowplot(18) +
    labs(x = "Fold change (observed/expected)", 
         y = NULL,
         title = title) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    scale_x_continuous(expand= c(0, 0), limits = c(0, max)) +
    scale_fill_manual(values = c("TRUE" = "dodgerblue3", "FALSE" = "grey50"))
  ggsave(paste0("gat/gat_bargraph_", gsub(" ", "_", title), ".pdf"), 
         p, 
         width = 8, 
         height = 3)
}
plot_single(data, "PPHLN1 FL binding to HUSH sites", 150)

## HUSH-HUSH2 unique sites
data_fl <- read.table("gat/gat_formatted_TASOR_TASOR2_unique_PPHLN1_FL.txt", header = TRUE)
data_fl$annotation <- gsub("_unique", "", data_fl$annotation)
data_fl$annotation <- factor(data_fl$annotation, levels = c("TASOR2", "TASOR"))

p <- ggplot(data_fl, aes(x = fold,
                         y = annotation,
                         fill = qvalue < 0.05)) +
  geom_col(colour = "black") +
  theme_cowplot(18) +
  labs(x = "Fold change (observed/expected)", 
       y = NULL,
       title = "PPHLN1 FL binding to unique TASOR/TASOR2 sites") +
  geom_vline(xintercept = 1, linetype = "dashed") +
  scale_x_continuous(expand= c(0, 0), limits = c(0, 100)) +
  scale_fill_manual(values = c("TRUE" = "dodgerblue3", "FALSE" = "grey50"))
ggsave(paste0("gat/gat_bargraph_PPHLN1_binding_to_uniqueTASOR1-2 sites.pdf"), 
       p, 
       width = 9, 
       height = 3)