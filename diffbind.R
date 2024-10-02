library(DiffBind)
library(tidyverse)

# Load sample sheet
sample_sheet <- read.csv("diffbind/sample_sheet.csv", header = TRUE)

# Load the DBA object
dba <- dba(sampleSheet = sample_sheet) %>%
    dba.blacklist(greylist = FALSE) %>%
    dba.count() %>%
    dba.normalize() %>%
    dba.contrast(minMembers = 2) %>%
    dba.analyze(design="~Condition",
                bGreylist=FALSE)

# Save dba object
save(dba, file = "diffbind/dba.RData")

# Plot correlation heatmap and PCA plot
pdf("diffbind/correlation_heatmap.pdf")
plot(dba)
dev.off()

pdf("diffbind/PCA.pdf")
dba.plotPCA(dba)
dev.off()

# Save fraction of reads in peaks
frip <- dba.show(dba)
write.csv(frip, 
          "diffbind/frip.csv", 
          row.names = FALSE, 
          quote = FALSE)

# Get contrast numbers with FL
contrasts <- dba$contrast
contrast_names <- lapply(contrasts, function(x) x$contrast)
FL_indices <- grep("FL", contrast_names)

# List to store amount of up and down DBs
df <- data.frame(contrast = character(), 
                 up = integer(), 
                 down = integer())

# Perform differential binding analysis
for (i in FL_indices) {
  name <- toString(contrast_names[[i]])
  name <- gsub("Condition, ", "", name)
  name <- gsub(", ", "_vs_", name)
  print(paste("Analyzing contrast:", name))
  
  # Plot volcano
  pdf(paste0("diffbind/volcano_", name, ".pdf"))
  dba.plotVolcano(dba, contrast = i)
  dev.off()
  
  # Get differential binding sites and write to file
  db <- as.data.frame(dba.report(dba, contrast = i))
  write.csv(db, 
            paste0("diffbind/DB_", name, ".csv"), 
            row.names = FALSE, 
            quote = FALSE)
  
  if (nrow(db) == 0) {
    df[nrow(df) + 1,] <- c(name, 0, 0)
  } else {
    df[nrow(df) + 1,] <- c(name, db %>% summarise(up = sum(Fold > 0), down = sum(Fold < 0)))
  }
  
  
  # Write all peaks to file (including non-DB)
  all_peaks <- as.data.frame(dba.report(dba, 
                                        th=1, 
                                        bCounts=TRUE, 
                                        contrast = i))
  write.csv(all_peaks,
            paste0("diffbind/all_peaks_", name, ".csv"),
            row.names = FALSE,
            quote = FALSE)
  
  if (nrow(db) > 100) {
    # Plot boxplot
    pdf(paste0("diffbind/boxplot_", name, ".pdf"))
    dba.plotBox(dba, contrast=i)
    dev.off()
    
    # Plot Venn diagram
    pdf(paste0("diffbind/venn_", name, ".pdf"))
    dba.plotVenn(dba, 
                 contrast = i,
                 bDB = TRUE,
                 bGain = TRUE, 
                 bLoss = TRUE, 
                 bAll = FALSE)
    dev.off()
    
    # Get matrix of p-values
    pvals <- dba.plotBox(dba, contrast = i, notch=FALSE)
    write.csv(pvals, 
              paste0("diffbind/pvals_", name, ".csv"), 
              row.names = TRUE, 
              quote = FALSE)
  }
}

# Write summary of diff binding sites to file
df$total <- as.numeric(df$up) + as.numeric(df$down)
write.csv(df, 
          "diffbind/diffbind_summary.csv", 
          row.names = FALSE, 
          quote = FALSE)
