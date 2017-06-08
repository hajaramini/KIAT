#!/bin/bash

# the purpose is to check the existence of B subgenome in Da-Ol
# although a previous run had 0 reads mapped to B subgenome, running a slitely different pipeline found all 505 have some B subgenome, so I need to try that pipeline on Da-Ol 

cd /Network/Servers/avalanche.plb.ucdavis.edu/Volumes/Mammoth/Users/ruijuanli/mapping_comparison_A_B_C_subgenome/mismatch_0/unique_mapped/2

sample=2_Unique.sorted_ABC.bam
chrom=`cat chrom_list_napus_plus_Bsub`

# index unique sorted bam file 
for i in $sample
	do
	echo $i
	samtools index $i
		for j in $chrom
		do
        	samtools view -@ 2 -b $i ${j} > ${j}.bam
        	samtools depth ${j}.bam -a > ${j}.depth  
	done
done

