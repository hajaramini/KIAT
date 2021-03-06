# load library
# source("http://www.bioconductor.org/biocLite.R")
# biocLite("multtest")
# install.packages("gplots")
# install.packages("LDheatmap")
# install.packages("genetics")
# install.packages("EMMREML") 
# install.packages("scatterplot3d")

library(multtest)
library(gplots)
# library(LDheatmap) # this could not be succesfully installed 
library(genetics)
library(EMMREML)
library(compiler) #this library is already installed in R
library("scatterplot3d")

# install GAPIT package 
source("http://zzlab.net/GAPIT/gapit_functions.txt")
# intall EMMA package 
source("http://zzlab.net/GAPIT/emma.txt")

# set working directory 
setwd("/Network/Servers/avalanche.plb.ucdavis.edu/Volumes/Mammoth/Users/ruijuanli/505/output/myGAPIT/")

######### load data
# genotype data 
geno_505_hmp <- read.table("~/505/vcf_leaf_no_pop/combined/505_filtered_sorted.hmp.txt", head=FALSE)
# get chrom name to numerics
geno_505_hmp$V3 <- as.numeric(geno_505_hmp$V3)
geno_505_hmp[1,3] <- "chrom"

# phenotype data 
load("~/505/data/phenotype/gh.seed.bolt.table.wide.Rdata")
# reform phentype data to have match taxa ID with geno data
# get taxa ID from sample description file 
sample_des_a_revised <- read.csv("~/505/data/phenotype/batch_a_revised.csv", header=T)
sample_des_b_revised <- read.csv("~/505/data/phenotype/batch_b_revised.csv", header=T)

sample_des_a_sub2 <- sample_des_a_revised[,c("Sample.ID", "No..of.Sowing", "Name")]
sample_des_a_sub2 <- sample_des_a_sub2[!is.na(sample_des_a_sub2$Sample.ID),]
sample_des_b_sub2 <- sample_des_b_revised[,c("Sample.ID", "No..of.Sowing", "Name")]
sample_des_sub2 <- rbind(sample_des_a_sub2, sample_des_b_sub2)

# add name to to replace SN 
sample_des_sub2$SN <- paste("K", sample_des_sub2$No..of.Sowing, sep="")
gh.seed.bolt.table.wide.merge <- merge(sample_des_sub2, gh.seed.bolt.table.wide, by = "SN")
pheno_data_505 <- gh.seed.bolt.table.wide.merge[,c("Sample.ID", "FATTY ACID_Erucic acid (C22:1n9)", "FATTY ACID_oil contents (%)", "FATTY ACID_Oleic acid (C18:1n9c)")]
colnames(pheno_data_505) <- c("Taxa", "Erucic_acid", "Oil_content", "Oleic_acid")
pheno_data_505

myY <- pheno_data_505
myG <- geno_505_hmp

# subset to get only 1st chromosome result 
# myG.01 <- myG[myG$V3==1,]
# myG.01.final <- data.frame(rbind(myG[1,], myG.01)) 

# run GAPIT 
myGAPIT <- GAPIT( 
Y=myY,
G=myG, 
PCA.total=3,
Geno.View.output=FALSE, 
PCA.View.output=FALSE 
)  

print("finished, YAAH!")


