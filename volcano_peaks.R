library(tidyverse)
library(cowplot)

# Load peak data (all peaks)
files <- Sys.glob("diffbind/all_peaks_*.csv")
names <- gsub("all_peaks_", "", basename(files))
names <- gsub(".csv", "", names)

# Create df with all peaks from all comparisons
df <- read.csv(files[1])
name <- gsub("all_peaks_", "", basename(files[1]))
name <- gsub(".csv", "", name)
colnames(df)[8] <- "Conc_mutant"
colnames(df)[ncol(df)-1] <- "mutant_1"
colnames(df)[ncol(df)] <- "mutant_2"
df$comparison <- name

for (i in 2:length(files)) {
  df2 <- read.csv(files[i])
  name <- gsub("all_peaks_", "", basename(files[i]))
  name <- gsub(".csv", "", name)
  colnames(df2)[8] <- "Conc_mutant"
  colnames(df2)[ncol(df2)-1] <- "mutant_1"
  colnames(df2)[ncol(df2)] <- "mutant_2"
  df2$comparison <- name
  df <- rbind(df, df2)
}

# Relevel comparison factor
df$comparison <- factor(df$comparison, 
                        levels = c("FL_vs_L356R",
                                   "FL_vs_L3xA",
                                    "FL_vs_1_127",
                                   "FL_vs_1_147",
                                   "FL_vs_1_222"))

# Create volcano plot for each comparison
p <- ggplot(df, aes(x = Fold, 
                    y = -log10(FDR))) +
  geom_point(aes(color = FDR < 0.05), 
             alpha = 0.5,
             size = 4) +
  #custom color fill
  scale_color_manual(values = c("red", "navy")) +
  facet_grid(~comparison, 
             scales = "fixed") +
  geom_hline(yintercept = -log10(0.05), 
             linetype = "dashed") +
  theme_cowplot(16) +
  theme(legend.position = "none") +
  labs(x = "log2(Fold Change)", 
       y = "-log10(FDR)") +
  coord_cartesian(xlim = c(-5.5, 5.5),
                  ylim = c(0, 5))

ggsave("paper_figures/volcano_peaks.pdf", 
       p, 
       width = 11, 
       height = 5)

ggsave("paper_figures/volcano_peaks.png", 
       p, 
       width = 11, 
       height = 5)

