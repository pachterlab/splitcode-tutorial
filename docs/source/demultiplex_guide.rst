Demultiplexing
==============

splitcode can demultiplex FASTQ files such that only reads containing certain tags or tag groups are discarded, reads containing certain tags or tag groups are removed, or reads are directed into separate files depending on the tags or tag groups identified.

Remove/Discard
^^^^^^^^^^^^^^

You can choose which tags or tag groups to discard by creating a file and supplying it to one of the following command-line option: 

* ``--remove`` (for tags)
* ``--remove-grp`` (for tag groups).

Let's say we have a config.txt file that contains three tags: **tag_A** and **tag_B** and **tag_C**, and we want to remove reads containing either a single instance of **tag_A** or of **tag_C**.

We can create a file, let's name it ``select.txt`` containing the tag names as follows:

.. code-block:: text
  :caption: select.txt

 tag_A
 tag_C

We can then run splitcode as follows:

.. code-block:: text

 splitcode -c config.txt --remove=select.txt [other options] [FastQ files]

.. hint::

  The **select.txt** file can also contain permutation of tags: e.g. if we want to remove reads containing **tag_B,tag_A,tag_C** each found exactly once and in that order, we can make that a line in the **select.txt** file.

Keep
^^^^

You can choose which tags or tag groups to retain by creating a file and supplying it to one of the following command-line option:

* ``--keep`` (for tags)
* ``--keep-grp`` (for tag groups).

Directing reads into other files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``--keep`` or ``keep-grp`` option additionally allows demultiplexing into separate files.

Let's say we have three groups: **grp_1**, **grp_2**, **grp_3** and we want to put the reads containing **grp_1,grp_2** (found exactly once and in that order) into one file and **grp_1,grp_3** into another file.

We can do so by creating a **select.txt** that contains the following:

.. code-block:: text
  :caption: select.txt

 grp_1,grp_2 fileA
 grp_1,grp_3 fileB

Now, let's say we have paired-end FASTQ files: ``R1.fastq`` and ``R2.fastq`` and we want to put all other reads (i.e. that don't meet the criteria above) into the files: ``unmapped_R1.fastq.gz`` and ``unmapped_R2.fastq.gz``.

We can demultiplex by running splitcode as follows:

.. code-block:: text

 splitcode -c config.txt --keep-grp=select.txt --gzip --nFastqs=2 --no-output --unassigned=unmapped_R1.fastq.gz,unmapped_R2.fastq.gz R1.fastq R2.fastq

The ``--gzip`` command means all our output files are compressed and ``--no-output`` means we don't have our usual output files (i.e. those specified by ``--pipe`` or ``-o``)

The following files will be produced:

* ``fileA_0.fastq.gz`` and ``fileA_1.fastq.gz``: Where the file

This option works the same as the remove option above, except the reads are kept rather than discarded. Note that when this option is specified, all other reads (i.e. the reads that are not kept) are tossed out.


What if you have a set of FASTQ files where each FASTQ file (or FASTQ file pair) is a single cell? This can be difficult to feed into programs that expect barcodes to be associated with each cell rather than having each cell be in a separate file.

Therefore, splitcode has a remultiplexing option where you can simply supply a batch file containing all the individual FASTQ files and splitcode will assign "fake" barcodes for each file supplied.

To do this, first create a ``batch.txt`` file as follows:

.. code-block:: text

 cell1  a_R1.fastq.gz a_R2.fastq.gz
 cell1  b_R1.fastq.gz b_R2.fastq.gz
 cell2  c_R1.fastq.gz c_R2.fastq.gz
 cell3  d_R1.fastq.gz d_R2.faastq.gz
 
Now simply run splitcode with the ``--remultiplex`` option as follows:

.. code-block:: shell

 splitcode --remultiplex -o out_R1.fastq.gz,out_R2.fastq.gz --outb=barcodes.fastq.gz batch.txt

The output files ``out_R1.fastq.gz`` and ``out_R2.fastq.gz`` will contain all the input FASTQ files from batch.txt concatenated together. The ``barcodes.fastq.gz`` file will contain unique barcodes corresponding to each cell, as specified in the batch.txt file. Note that cell1 appears twice in the batch.txt file; therefore both pairs of files (beginning with **a_** and **b_**) will have their reads associated with the same barcode. The barcodes will be 16-bp in length and will look like **AAAAAAAAAAAAAAAA** (for **cell1**), **AAAAAAAAAAAAAAAC** (for **cell2**), and **AAAAAAAAAAAAAAAG** (for **cell3**).

There are multiple ways to output the barcodes that are made from remultiplexing:

* You can supply the ``--outb`` option to have the barcodes supplied in a separate file (as was done above).
* You can supply the ``--bc-names`` option to put the barcode after the ``BC:Z:`` SAM tag in the read header.
* You can supply the ``--com-names`` option to put the unique numerical ID after the ``BI:i:`` SAM tag in the read header.
* You can supply the ``--pipe`` option so that the barcode is interleaved with the reads.
* You can omit the ``--outb`` option which will cause, by default, the barcode to appear at the very beginning of each read in the first (R1) read file.
