#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(PhenotypeSimulator)

# plink2 --bfile chr_EUR_sim_snps --recode vcf --out chr_EUR_sim_snps
# plink2 --vcf chr_EUR_sim_snps.vcf --make-bed --out _chr_EUR_sim_snps

#args[1] <- wd
#args[2] <- readgenotypes
#args[3] <- save to
#args[4] <- # samples
#args[5] <- # of snps
#args[6] <- genvar
#args[7] <- h2s


# args<-c("./", 
# 	"data2/chr_ph_ss_K10_filt_sim_snps",
# 	"data2/chr_ph_ss_K10_m0.5_sd0.3_gv0.5_h2s0.5_phenos.tsv",
# 	"5000", 
# 	"10", 
# 	"0.5", 
# 	"0.5", 
# 	"1.0",
#        "0.5",
#        "0.3")
#	/home/achangalidi/ukb_finngen/1000genomes chr_EUR_sim_snps phenos.tsv 5000 20 0.5 0.5 0.5


WD <- args[1]
geno_file <- args[2]
pheno_file <- args[3]
N_samples <- as.numeric(args[4])
N_genes <-as.numeric(args[5])
genVar <- as.numeric(args[6]) #!!! 
h2s <- as.numeric(args[7]) # доля от генвар, которую составля.т эффекты моих снипов

mBeta <- as.numeric(args[8])
sdBeta <- as.numeric(args[9])

pIndependentGenetic <- as.numeric(args[10]) #proportion of genetic variant effects to have a trait-independent fixed effect
phi <- as.numeric(args[11])

setwd(WD)


genotypes <- readStandardGenotypes(N=N_samples, 
					filename=geno_file,
					format="plink")

phenotype <- runSimulation(N = N_samples, 
                           P = 1, 
                           genotypefile = geno_file,
                           cNrSNP=N_genes, 
                           format="plink",
                           genVar = genVar, 
                           h2s = h2s, 
                           mBetaGenetic = mBeta, 
                           sdBetaGenetic = sdBeta,
                           pIndependentGenetic = pIndependentGenetic,
                           phi = phi,
                           verbose = TRUE)


print("Saving...")
Y <- phenotype$phenoComponentsFinal$Y

row.names(Y) <- genotypes[["id_samples"]]
Y <- as.data.frame(Y)
Y[["t1"]] <- Y[["Trait_1"]]
Y[["#FID"]] <- row.names(Y) 
Y[["IID"]] <- sub("id1", "id2", Y[["#FID"]])

write.table(Y[c("#FID", "IID", "t1")], file=pheno_file, quote=FALSE, sep='\t', col.names = TRUE, row.names=FALSE)

print(paste0('Pheno wrote to: ', pheno_file))



