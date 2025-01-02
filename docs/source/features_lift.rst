Lift
====

Introduction
------------

An auxiliary feature of ``splitcode`` is the ability to modify FASTA files with variants from VCF files, updates GTF annotations to reflect new coordinates, extracts nucleotide windows around variants, and extract nucleotide windows around splice junctions stored in splice junction files (SJ.out.tab files produced by `STAR <https://github.com/alexdobin/STAR>`_ alignment). The feature is called "lift" for the ability to lift variant data onto sequences.

The ability of splitcode to modify FASTA/GTF files with variant data is effectively a re-implementation of most of `g2gtools <https://github.com/churchill-lab/g2gtools>`_. The 'bcftools consensus' command in `bcftools <https://samtools.github.io/bcftools/howtos/index.html>`_ also provides the ability modify FASTA files with VCF input.

The ability to extract nucleotide variants surrounding variants facilitates aligning sequencing reads to variant or mutation data.



VCF files
---------


Basic usage
^^^^^^^^^^^

An example use case might be lifting a mouse strain's SNP and/or indel variants stored in a `mouse genome VCF file <https://ftp.ebi.ac.uk/pub/databases/eva/PRJEB53906/>`_ onto the `mouse reference genome <https://ftp.ensembl.org/pub/release-113/fasta/mus_musculus/dna/>`_ and also outputting a GTF file (modified from the `mouse reference genome GTF file <https://ftp.ensembl.org/pub/release-113/gtf/mus_musculus/>`_) accounting for new coordinates after indels have been added in. Let's say we want to do this for the CAST/EiJ mouse strain (named CAST_EiJ in the VCF file). Given the VCF file (variants.vcf.gz), the reference genome FASTA file (genome.fa.gz), and the reference genome GTF file (genome.gtf), we can do:

.. code-block:: shell

  splitcode --lift genome.fa.gz variants.vcf.gz CAST_EiJ \
   --rename --ref-gtf genome.gtf --out-gtf output.gtf > output.fasta

The output FASTA sequences were directed into an output.fasta file and the new GTF annotations were written into output.gtf. (We use the --rename option so that each chromosome name in output.fasta file is renamed; each chromosome name will get the prefix "CAST_EIJ_" added to it.)



Diploid mode
^^^^^^^^^^^^



Nucleotide windows
^^^^^^^^^^^^^^^^^^


Splice junctions
----------------



Usage information
-----------------


.. code-block:: text

  splitcode --lift <ref_fasta> <vcf_file> <sample> [--diploid] [--filter] [--rename] [--snv-only] [--ref-gtf <ref_gtf>] [--out-gtf <out_gtf>]


  Options for contig extraction: 
      --kmer-length=INT       Length of the k-mers that contain the variant
      --kmer-output=STRING    Filename for k-mer output sequences
      --kmer-header=STRING    The header of the sequences in the FASTA output (default: the variant IDs in the VCF file)
      --kmer-header-num       If specified, will append a number (in increasing numerical order) to each header
      --kmer-sj               Extracts k-mer spanning splice junctions following a given SJ file. See usage below.
                              splitcode --lift --kmer-sj <ref_fasta> <SJ_file> [additional k-mer options]


References
^^^^^^^^^^

The following references, which either describe the method, were posted prior to, or contributed to the development of this tutorial, are acknowledged and credited:

1. `g2gtools <https://github.com/churchill-lab/g2gtools>`_
2. `bcftools <https://samtools.github.io/bcftools/howtos/index.html>`_
3. Dobin A, Davis CA, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P, Chaisson M, Gingeras TR. STAR: ultrafast universal RNA-seq aligner. Bioinformatics. 2013 Jan;29(1):15-21. `https://doi.org/10.1093/bioinformatics/bts635 <https://doi.org/10.1093/bioinformatics/bts635>`_




