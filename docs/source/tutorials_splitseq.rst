.. _SPLITSEQ guide:

SPLiT-seq processing
====================

Introduction
^^^^^^^^^^^^

SPLiT-seq (Parse Biosciences) utilizes three rounds of combinatorial barcoding. A protocol might look as follows (and is what will be used in this tutorial):

* Round 1 barcode (8 bps): Position 78-86 in R2.fastq.gz
* Round 2 barcode (8 bps): Position 48-56 in R2.fastq.gz
* Round 3 barcode (8 bps): Position 10-18 in R2.fastq.gz
* Biological read: The R1.fastq.gz file.

Note: The round 1 barcode (position 78-86 in R2.fastq.gz) has two types of reads: 1) random oligo primed reads (**R**), and 2) polyT primed reads (**T**). These are distinguished by the round 1 barcodes (there are 96 R barcodes and 96 T barcodes. Therefore, two possible barcodes can belong to a single cell. It would be desirable to analyze them separately (because of technical biases). However, one may alternatively want to convert R barcodes to their corresponding T barcodes (as is done in many pipelines) so that each cell gets a single barcode; this is what we'll do in the following section.


Example: Convert R to T
^^^^^^^^^^^^^^^^^^^^^^^

We create a config file, `config_RT.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/config_RT.txt>`_, where each R barcode is specified to be replaced with its corresponding T barcode.

We then run splitcode on the R2.fastq.gz file as follows:

.. code-block:: text

   splitcode -c config_RT.txt -o modified_R2.fq.gz R2.fastq.gz

.. tip::

   Instead of generating an output file via ``-o``, one can use ``-p`` instead to pipe output to standard output (and then direct the standard output directly into a downstream read processing/alignment program).



Example: Barcode reformatting
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here, we'll address producing a final "corrected" barcode with all three barcoding rounds stitched together.

TODO



Example: Demultiplexing wells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The 96-well plate contains 8 rows (A-H) and 12 columns (1-12). Each well can be identified by the first round of split-pool barcoding. For example purposes, let's say wells A1-A8 were used for one experiment, wells B1-B8 were used for a second experiment, wells C1-C8 were used for a third experiment, and wells D1-D8 were used for a fourth experiment. We want to separate those 4 experiments into their own FASTQ files.

We can so by creating a config file, `config_separate.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/config_separate.txt>`_, four files containing the barcodes for each experiment: `A1_A8.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/A1_A8.txt>`_, `B1_B8.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/B1_B8.txt>`_, `C1_C8.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/C1_C8.txt>`_, `D1_D8.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/D1_D8.txt>`_, and then a `select_wells.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/splitseq/select_wells.txt>`_ file specifying the demultiplexing strategy (i.e. barcodes go into certain files based on their experiment/group). We then run the following:


.. code-block:: shell

   splitcode -c config_separate.txt --nFastqs=2 \
   --gzip --keep-grp=select_wells.txt \
   --no-output --no-outb \
   R1.fastq.gz R2.fastq.gz

The output will consist of a pair of files for each experiment:

* ``A1_A8_0.fastq.gz`` and ``A1_A8_1.fastq.gz``
* ``B1_B8_0.fastq.gz`` and ``B1_B8_1.fastq.gz``
* ``C1_C8_0.fastq.gz`` and ``C1_C8_1.fastq.gz``
* ``D1_D8_0.fastq.gz`` and ``D1_D8_1.fastq.gz``

Where ``_0.fastq.gz`` corresponds to ``R1`` and ``_1.fastq.gz`` corresponds to ``R2`` (because splitcode uses zero-indexing).



Example: Long-read SPLiT-seq
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TODO

References
^^^^^^^^^^

The following references, which either describe the method, were posted prior to, or contributed to the development of this tutorial, are acknowledged and credited:

1. Rosenberg AB, Roco CM, Muscat RA, Kuchina A, Sample P, Yao Z, Graybuck LT, Peeler DJ, Mukherjee S, Chen W, Pun SH. Single-cell profiling of the developing mouse brain and spinal cord with split-pool barcoding. Science. 2018 Apr 13;360(6385):176-82. `https://doi.org/10.1126/science.aam8999 <https://doi.org/10.1126/science.aam8999>`_

2. Rebboah E, Reese F, Williams K, Balderrama-Gutierrez G, McGill C, Trout D, Rodriguez I, Liang H, Wold BJ, Mortazavi A. Mapping and modeling the genomic basis of differential RNA isoform expression at single-cell resolution with LR-Split-seq. Genome biology. 2021 Dec;22(1):1-28. `https://doi.org/10.1186/s13059-021-02505-w <https://doi.org/10.1186/s13059-021-02505-w>`_

3. `Preprocess_SPLITseq_collapse_bcSharing.pl <https://github.com/jeremymsimon/SPLITseq>`_ (a perl script to convert R barcodes to T barcodes)

4. `splitp <https://github.com/COMBINE-lab/splitp>`_ (a rust implementation of the previous perl script)

5. `LR-splitpipe <https://github.com/fairliereese/LR-splitpipe>`_ (used for processing long read SPLiT-seq data)



