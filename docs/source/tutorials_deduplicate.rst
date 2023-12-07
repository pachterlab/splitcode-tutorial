.. _DEDUP guide:

Deduplication by barcode
========================

Introduction
^^^^^^^^^^^^

splitcode assigns a "final" barcode to reads when ``--assign`` is used, which can be outputted into its own FASTQ file that is paired with the reads. In this section, we will use the final barcodes to deduplicate sequencing reads (e.g. to account for PCR bias) such that only duplicates *within each final barcode* are collapsed. This is useful in single-cell data where one may want to deduplicate sequences on a per-cell basis but the technology lacks UMIs.

To accomplish deduplication, we will make use of the excellent `BBTools <https://jgi.doe.gov/data-and-tools/software-tools/bbtools/>`_ suite of software (Bushnell B., `sourceforge.net/projects/bbmap/ <sourceforge.net/projects/bbmap/>`_; Bushnell B, Rood J, Singer E. BBMerge–accurate paired shotgun read merging via overlap. PloS one. 2017 Oct 26;12(10):e0185056. `https://doi.org/10.1371/journal.pone.0185056 <https://doi.org/10.1371/journal.pone.0185056>`_). Specifically, we will use ``clumpify.sh`` from that suite of software.

One can download BBTools from the sourceforge link above. This guide makes use of **version 39.06** of the software:

.. code-block:: shell

   wget https://downloads.sourceforge.net/project/bbmap/BBMap_39.06.tar.gz
   tar -xzvf BBMap_39.06.tar.gz


Walkthrough
^^^^^^^^^^^

We provide the final assigned barcodes file (``barcodes.fastq.gz``) and a reads file (``reads.fastq.gz``), both of which were produced from a previous splitcode run. (Note: If more than one reads file exists, it would be necessary to merge the reads together).

We run the following, specifying a large k-mer size of 31 to avoid the barcodes file (16-bp barcodes) from being accounted for in the deduplication. Furthermore, we specify an error tolerance of two substitutions when deduplicating.

.. code-block:: text

   clumpify.sh k=31 dedupe=t subs=2 \
   in=barcodes.fastq.gz in2=reads.fastq.gz \
   out=out_barcodes.fastq.gz out2=out_reads.fastq.gz

The output files ``out_barcodes.fastq.gz`` and ``out_reads.fastq.gz`` will still be paired together and will contain the results of the deduplication.



