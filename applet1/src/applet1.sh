#!/bin/bash

set -e -x -o pipefail

main() {
    sleep 1
    dx download "$fastq" -o input.fastq
    mkdir genome
    dx cat "$genomeindex_targz" | tar zxvf - -C genome
    genome_file=`ls genome/*.bwt`
    genome_file="${genome_file%.bwt}"

    bwa mem -t `nproc` -r 1.0 -k 15 -w 150 "$genome_file" input.fastq | samtools view -u -S - | samtools sort -m 256M -@ `nproc` - output

    bam=$(dx upload output.bam --brief)

    dx-jobutil-add-output bam "$bam" --class=file
}
