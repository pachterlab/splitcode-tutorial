.. _SMARTSEQ3 guide:

Separating Smart-seq3 reads
===========================

Introduction
^^^^^^^^^^^^

Smart-seq3 is a technology that produces both strand-specific 5′ UMI-containing reads and internal reads (the internal reads are unstranded and provide coverage over the full length of the transcript). It is often desirable to separate these two types of reads.

Smart-seq3 data (as originally published) has four files:
* I1.fastq.gz: The first component of the cell barcode
* I2.fastq.gz: The second component of the cell barcode
* R1.fastq.gz: The first read, which, if internal, is purely biological; and if, UMI, will have an 11-bp tag sequence (ATTGCGCAATG) followed by an 8-bp UMI followed by a 3-bp GGG.
* R2.fastq.gz: The second read (an entirely biological read); for single-end reads protocols, this file will not exist.

Separating UMI reads from internal reads
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We will separate UMI-containing reads from internal (int) reads, and trim off the 11-bp tag sequence from the UMI-containing reads.

First, create the following ``config.txt`` file, which specifies that we'll search for the 11-bp tag sequence within the first 11-bp of the third read file (``2:0:11`` as the location) and allowing a one hamming distance mismatch when searching for that sequence (``1`` as the distance). We specify ``left``, indicating that we'll trim the tag off when we find it and we specify ``minFinds``, indicating that the tag must be found once to be considered "assigned" (the other reads will be considered unassigned and will be outputted into the files supplied to the ``-u`` option).

.. code-block:: text
  :caption: config.txt

   tags          distances  locations  minFinds  left
   ATTGCGCAATG   1          2:0:11     1         1


Then, run the following:

.. code-block:: shell

   splitcode -c config.txt --nFastqs=4 --gzip \
   -o I1_umi.fastq.gz,I2_umi.fastq.gz,R1_umi.fastq.gz,R2_umi.fastq.gz \
   -u I1_int.fastq.gz,I2_int.fastq.gz,R1_int.fastq.gz,R2_int.fastq.gz \
   I1.fastq.gz I2.fastq.gz R1.fastq.gz R2.fastq.gz

The UMI reads and the internal (int) reads will now be separated. The R1_umi.fastq.gz will have the 11-bp tag trimmed off from the left end.

If we have single-end reads (i.e. the R2.fastq.gz file does not exist), then we can simply omit the R2 files from the above command and set ``--nFastqs=3``.



References
^^^^^^^^^^

The following references, which either describe the method, were posted prior to, or contributed to the development of this tutorial, are acknowledged and credited:

1. Hagemann-Jensen M, Ziegenhain C, Chen P, Ramsköld D, Hendriks GJ, Larsson AJ, Faridani OR, Sandberg R. Single-cell RNA counting at allele and isoform resolution using Smart-seq3. Nature Biotechnology. 2020 Jun;38(6):708-14. `https://doi.org/10.1038/s41587-020-0497-0 <https://doi.org/10.1038/s41587-020-0497-0>`_

