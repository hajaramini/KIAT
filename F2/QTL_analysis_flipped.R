### Goal of this project: to map QTL using the genetic map that I constructed from F2 mapping population created from Da-Ae & Da-Ol-1   

### load lib
library(tidyverse)
library(qtl)
library(snowfall)
library(ggrepel)  
library(Biostrings)
source("~/KIAT/function_BnRNAseq.R")    

### load data and run scanone & cim 
LG.f2.after.crossover <- read.cross("csvsr", genfile = "~/F2/data/QTL_analysis/LG.f2.madmapper.final_gen_revised_flipped.csv", 
                     phefile = "~/F2/data/QTL_analysis/F2.pheno.csv", 
                     genotypes = c("AA", "AB", "BB")) # the only problem is that 44 phenotypes were read instead of 43, need to figure out why later  

# plot.map(F2.map)
# summaryMap(F2.map) # 2884 

LG.f2.after.crossover <- sim.geno(LG.f2.after.crossover,step=1,n.draws=32) # imputation  
LG.f2.after.crossover <- calc.genoprob(LG.f2.after.crossover,step=1) # calculate the probability of the true underlying genotypes given the observed multipoint marker data --> for each imputed data, give a probability? 

sfInit(parallel = TRUE, cpus = 4) 
sfExport("LG.f2.after.crossover")
sfLibrary(qtl)

system.time(
scanone.perm.imp <- 
  sfLapply(seq_along(LG.f2.after.crossover$pheno), function(trait){
    print(trait) # print doesn't work in here 
    tmp <-scanone(LG.f2.after.crossover,pheno.col = trait, method="imp",n.perm=1000, n.cluster = 16)
    summary(tmp)[1] # #keep the 95th percentile for future use.This corresponds to p <0.05
  }) # takes 40 mins to finish 
)
sfStop() 

names(scanone.perm.imp) <- colnames(LG.f2.after.crossover$pheno)
save(scanone.perm.imp, file = "~/F2/output/QTL_analysis/scanone.perm.imp.43traits.flipped")

# Erucic acid 
scanone.imp.Erucic <- scanone(LG.f2.after.crossover,pheno.col=15,method="imp") # 
plot(scanone.imp.Erucic,bandcol="gray90", main="Erucic_acid")
abline(h=scanone.perm.imp[["Erucic_acid"]],lty=2) #add permuation threshold

# Oleic acid 
scanone.imp.Oleic <- scanone(LG.f2.after.crossover,pheno.col=8,method="imp") # 
plot(scanone.imp.Oleic,bandcol="gray90", main="Oleic_acid")
abline(h=scanone.perm.imp[["Oleic_acid"]],lty=2) #add permuation threshold

system.time(
scanone.imp <- 
lapply(seq_along(LG.f2.after.crossover$pheno[1:43]), function(trait) {
  print(trait)
  scanone(LG.f2.after.crossover,pheno.col=trait,method="imp")
}) 
)
names(scanone.imp) <- colnames(LG.f2.after.crossover$pheno)[1:43]

png("~/F2/output/QTL_analysis/figure/QTL_one_dim_flipped.png", width=25, height=15, units="in", res=300)
par(mfrow=c(6,7))

for (i in names(scanone.imp)){
  plot(scanone.imp[[i]],bandcol="gray90", main=i)
  abline(h=scanone.perm.imp[[i]],lty=2)
}

dev.off()  

save(scanone.imp, file = "~/F2/output/QTL_analysis/scanone.imp.43traits.flipped")

cim.qtl <- 
lapply(seq_along(LG.f2.after.crossover$pheno)[1:43], function(trait) {
  print(trait)
  cim(LG.f2.after.crossover, n.marcovar=5, pheno.col=trait,method="em")
}) 
# here we use the interval mapping method "em" as this is how cim was originaly implmented.the n.marcovar= argument defines the maximum number of marker covariates to use.
names(cim.qtl) <- colnames(LG.f2.after.crossover$pheno)[1:43]

sfInit(parallel = TRUE, cpus = 4)  
sfExport("LG.f2.after.crossover")
sfLibrary(qtl)  

cim.perm <- 
  sfLapply(seq_along(LG.f2.after.crossover$pheno)[1:43], function(trait){
    message(trait) # message doesn't work in here either 
    tmp <- cim(LG.f2.after.crossover,
               pheno.col = trait, 
               n.marcovar=5, 
               method="em",
               n.perm=1000)
    summary(tmp)[1] # #keep the 95th percentile for future use.This corresponds to p <0.05
  }) # takes almost 4 hours to finish 

sfStop()  

names(cim.perm) <- colnames(LG.f2.after.crossover$pheno)[1:43]

# plot out result and save plot 
png("~/F2/output/QTL_analysis/figure/QTL_cim_1_flipped.png", width=25, height=15, units="in", res=300)
par(mfrow=c(6,7))

for (i in names(cim.qtl)){
  plot(cim.qtl[[i]],bandcol="gray90", main=i)
  abline(h=cim.perm[[i]],lty=2)
}

dev.off()  
# more QTL found for cim method 

save(cim.qtl, file = "~/F2/output/QTL_analysis/cim.qtl.43traits.flipped.Rdata")
save(cim.perm, file = "~/F2/output/QTL_analysis/cim.perm.43traits.flipped.Rdata") 









 
