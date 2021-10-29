#! /usr/bin/env nextflow

//vim: syntax=groovy -*- mode: groovy;-*-

// Copyright (C) 2021 IRB Barcelona

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


params.help = null
params.input_folder = null
params.input_file = null
params.mem = 8
params.output_folder = "BAM_merged"

log.info ""
log.info "--------------------------------------------------------"
log.info "  vcf_normalization-nf 1.1.0: Nextflow pipeline for vcf normalization    "
log.info "--------------------------------------------------------"
log.info "Copyright (C) IARC/WHO"
log.info "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE"
log.info "This is free software, and you are welcome to redistribute it"
log.info "under certain conditions; see LICENSE for details."
log.info "--------------------------------------------------------"
log.info ""

if (params.help) {
    log.info ''
    log.info '--------------------------------------------------'
    log.info '  USAGE              '
    log.info '--------------------------------------------------'
    log.info ''
    log.info 'Usage: '
    log.info 'nextflow run iarcbioinf/vcf_normalization-nf --vcf_folder VCF/ --ref ref.fasta'
    log.info ''
    log.info 'Mandatory arguments:'
    log.info '    --input_file         FOLDER                  File containing the output file and files to merge, in lines.'
    log.info '    --input_folder       FOLDER                  Folder containing the input files.'
    log.info 'Optional arguments:'
    log.info '    --output_folder      FOLDER                  Output folder (default: BAM_merged).'
    log.info '    --mem                INTEGER                 Size of memory used for mapping (in GB) (default: 8).'
    log.info ''
    exit 0
}

assert (params.input_file != true) && (params.input_file != null) : "please specify --input_file option "

files_to_merge = Channel.fromPath("${params.input_file}")
                        .splitCsv()
			                  .map { row -> tuple(row[0], row[1], params.input_folder + "/" + row[2], params.input_folder + "/" + row[3]) }

process merge {

    memory params.mem+'GB'
    tag { SM }
    
    publishDir "${params.output_folder}", mode: 'copy' 

    input:
    set val(SM), val(outfile), file(bam1), file(bam2) from files_to_merge


    output:
    file("*sm_merged.bam*") into bam_merged
    
    shell:
    '''
    samtools merge !{outfile} !{bam1} !{bam2}
    '''

}