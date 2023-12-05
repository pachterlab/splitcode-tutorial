.. _DemuxCells guide:

Demultiplex single-cells into individual files
==============================================

Let's say you have single-cell sequencing reads, such as those produced by 10x Genomics, where the 16 bp barcodes (used to label individual cells) are at the beginning of the first read file (R1.fastq) but you want to put each individual cell into its own file. This can be done using splitcode's demultiplexing capabilities (see the page: :ref:`demultiplexing page` for a more detailed description of splitcode's demultiplexing capabilities).

Here, we'll create the following ``config.txt`` file:

.. code-block:: text
  :caption: config.txt

   tags                 locations  distances
   GACGTAGCGCCCCCCA     0:0:16     1
   TAGCTACCTTGTAACA     0:0:16     1
   CCACCGAATAGGAACC     0:0:16     1
   TTGTAGCTGAGTAGTA     0:0:16     1
   CCTTCCTTAAACTTAC     0:0:16     1
   CCTTCCTTAAACTTAG     0:0:16     1

We showcase a series of 16 bp barcodes and specify that it occurs at the beginning (i.e. first 16 bps) of the first sequencing read via ``0:0:16`` and a hamming distance error of ``1`` (one substitution) is allowed. Of course, single-cell technologies can have thousands of barcodes, all of which would be put into this file via this format, but we only show a few here for demonstration purposes.

Next, we'll create the following ``keep.txt`` file for our demultiplexing strategy (the first column is the tag ID, which by default is the tag sequence itself, and the second column is the prefix of the output file name):

.. code-block:: text
  :caption: keep.txt

   GACGTAGCGCCCCCCA	1
   TAGCTACCTTGTAACA	2
   CCACCGAATAGGAACC	3
   TTGTAGCTGAGTAGTA	4
   CCTTCCTTAAACTTAC	5
   CCTTCCTTAAACTTAG	6


We then run the following:

.. code-block:: text

   splitcode --gzip --keep=keep.txt -c config.txt --nFastqs=2 --no-output --no-outb R1.fastq R2.fastq

We use ``--no-output`` because we don't have our "typical output" (i.e. those specified by ``--pipe`` or ``-o``; for all entries in **select.txt** where the second column is blank, those would go into the "typical output"). We use ``-no-outb`` because we don't have any "final barcodes" (since ``--assign`` is not specified) so we shouldn't allocate files for them.

The following six pairs of files will be generated (the _0.fastq.gz files are the R1 files and the _1.fastq.gz files are the R2 files, since, remember, splitcode file numbers are zero-indexed):

* ``1_0.fastq.gz`` and ``1_1.fastq.gz``
* ``2_0.fastq.gz`` and ``2_1.fastq.gz``
* ``3_0.fastq.gz`` and ``3_1.fastq.gz``
* ``4_0.fastq.gz`` and ``4_1.fastq.gz``
* ``5_0.fastq.gz`` and ``5_1.fastq.gz``
* ``6_0.fastq.gz`` and ``6_1.fastq.gz``

Each of these files will contain the barcodes associated with the respective files (e.g. reads with the barcode TTGTAGCTGAGTAGTA will be thrown into the files prefixed with 4, i.e. 4_0.fastq.gz and 4_1.fastq.gz).
