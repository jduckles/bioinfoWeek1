#!/bin/bash

##### Description
# This script will multiple sequence files, concatenate them into a single file, join paired ends, and then split them into their respective libraries.
# The script assumes you are in the directory you'll be analyzing the data in, and assumes your files are in seq/. 
# 

##### Needed software
# QIIME (1.9.0)
# PEAR https://github.com/xflouris/PEAR . Head there and install PEAR if you haven't already.

##### Needed Files
# A QIIME compatible mapping file. Run valiate_mapping_file.py (Help at http://qiime.org/scripts/validate_mapping_file.html) to make sure your file is in the correct format.
# Sequence files in the seq/ directory.

# Concatenate R1 and R2 files into single files
echo "Joining your files"
cat seq/R1_1.fastq seq/R1_2.fastq seq/R1_3.fastq seq/R1_4.fastq > seq/R1.fastq
cat seq/R2_1.fastq seq/R2_2.fastq seq/R2_3.fastq seq/R2_4.fastq > seq/R2.fastq

# Join R1 and R2 reads using PEAR, a Paired-End reAd mergeR
pear -f seq/R1.fastq -r seq/R2.fastq -o seq/Amp -p 0.001 -v 100 -m 450 -n 250 -y 500m -j 1

# Use QIIME to prepare your FASTQ files. 
echo “Starting… Extracting barcodes”
extract_barcodes.py -a -f seq/Amp.assembled.fastq -m seq/tags.txt -l 12 -o seq/prepped/

# Use QIIME to demultiplex the data, with -q 0. Store output as fastq format (we will quality filter with usearch). This part of the analysis was taken from suggestions within the QIIME forums on best practices to integrate UPARSE into a usable QIIME workflow.
echo “Splitting Libraries”
split_libraries_fastq.py -i seq/prepped/reads.fastq -b seq/prepped/barcodes.fastq -m seq/tags.txt --barcode_type 12 -o seq/SlOut/

echo "All done- check out the results of split_libraries_fastq.py in the seq/SlOut/ directory."
