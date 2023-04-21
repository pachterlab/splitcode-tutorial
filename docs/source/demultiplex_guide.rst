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

We can do so by creating a two-column **select.txt** that contains the following:

.. code-block:: text
  :caption: select.txt

  grp_1,grp_2 fileA
  grp_1,grp_3 fileB

Now, let's say we have paired-end FASTQ files: ``R1.fastq`` and ``R2.fastq`` and we want to put all other reads (i.e. that don't meet the criteria above) into the files: ``unmapped_R1.fastq.gz`` and ``unmapped_R2.fastq.gz``.

We can demultiplex by running splitcode as follows:

.. code-block:: text

 splitcode -c config.txt --keep-grp=select.txt --gzip --nFastqs=2 --no-output --unassigned=unmapped_R1.fastq.gz,unmapped_R2.fastq.gz R1.fastq R2.fastq

The ``--gzip`` command means all our output files are compressed and ``--no-output`` means we don't have our "typical output" (i.e. those specified by ``--pipe`` or ``-o``; for all entries in **select.txt** where the second column is blank, those would go into the "typical output").

The following files will be produced:

* ``fileA_0.fastq.gz`` and ``fileA_1.fastq.gz``: Where the fileA outputs (**grp_1,grp_2**) will be written to. Note that **_0** means the first file in the read group (i.e. the R1 file in this case), and the **_1** means the second file in the read group (i.e. the R2 file in this case). These suffixes (i.e. _0, _1, _2, _3, etc.) are used because **--nFastqs** might be some larger number and we'll need to keep track of the order of reads in the read group.
* ``fileB_0.fastq.gz`` and ``fileB_1.fastq.gz``: Where the fileB outputs (**grp_1,grp_3**) will be written to. Similar concept to the *fileA* outputs described above.
* ``fileA_barcodes.fastq.gz`` and ``fileB_barcodes.fastq.gz``: These contain the final barcodes for the fileA files and the fileB files if **--assign** is specified (without **--assign**, these files will just be empty).
* ``unmapped_R1.fastq.gz`` and ``unmapped_R2.fastq.gz``: These are the files where we specified that the unmapped reads (i.e. those that don't fall into anything in select.txt) will be written into.



