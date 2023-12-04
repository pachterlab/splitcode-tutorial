.. _SPRITE guide:

SPRITE barcodes
===============

Introduction
^^^^^^^^^^^^

SPRITE is a technique whereby interacting genomic regions can be identified by clusters of sequences that share the same barcode. The barcodes are the product of split-pool barcoding and therefore the first step is identify those cluster barcodes.

Read structure
^^^^^^^^^^^^^^

The read structure is as follows:

.. image:: https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/sprite/sprite_layout.png
  :width: 725
  :alt: SPRITE image


The reads, in accordance with the original SPRITE manuscript, are processed as follows:

1. The first 8 bp's of read 1 are searched for an *exact* match to a **DPM** tag. No mismatch errors are allowed.
2. The beginning of read 2 is scanned for a **Y** tag, which varies from 9-12 bases. The tag must be anchored to the beginning (5' end) of the read and cannot have mismatches.
3. Starting from 15 bp's after the start of read 2, a 15-bp **ODD** tag is searched for (allowing hamming distance 2 mismatch). If the Y tag was found in the previous step, the next tag must be an ODD tag and 6-12 bases are allowed in between that ODD tag and the previous Y tag (because each tag is separated by a *spacer* region).
4. Starting from 30 bp's after the start of read 2, a 15-bp **EVEN** tag is searched for (allowing hamming distance 2 mismatch). If an ODD tag was found in the previous step, the next tag must be an EVEN tag and 6-12 bases are allowed in between that EVEN tag and the previous ODD tag (because each tag is separated by a *spacer* region).
5. Finally, an ODD tag is searched for again (allowing hamming distance 2 mismatch). If an EVEN tag was found in the previous step, the next tag must be an ODD tag and 6-12 bases are allowed in between that ODD tag and the previous EVEN tag (because each tag is separated by a *spacer* region).

The **config file** is located at `sprite_config.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/sprite/sprite_config.txt>`_

Processing
^^^^^^^^^^

We will use the `SRR7216015 <https://www.ncbi.nlm.nih.gov/sra/?term=SRR7216015>`_ FASTQ files as an example. We run the following:

.. code-block:: shell

   splitcode --assign -N 2 -o SRR7216015_o1.fastq.gz,SRR7216015_o2.fastq.gz \
   --unassigned=SRR7216015_u1.fastq.gz,SRR7216015_u2.fastq.gz --outb=barcodeids.fq.gz \
   -c sprite_config.txt --keep-grp=<(echo "DPM,Y,ODD,EVEN,ODD") --mod-names \
   --gzip --mapping=mapping.txt SRR7216015_1.fastq.gz SRR7216015_2.fastq.gz

Note that for ``--keep-grp``, we specified ``<(echo "DPM,Y,ODD,EVEN,ODD")``. We could have put **DPM,Y,ODD,EVEN,ODD** into a separate file and supplied that separate file name, but, for simplicity, we just used a process substitution to create an anonymous pipe.

.. hint::

   You can add **left** and/or **right** columns to the sprite config file to trim tags (e.g. remove the DPMs). You can additionally apply quality trimming via the *qtrim* option, which will happen afterwards.


Output
^^^^^^

The output contains 6 files:

* **SRR7216015_o1.fastq.gz** and **SRR7216015_o2.fastq.gz**: The assigned reads files, i.e. the R1 and R2 files with the five tags (DPM,Y,ODD,EVEN,ODD) identified in order.
* **SRR7216015_u1.fastq.gz** and **SRR7216015_u2.fastq.gz**: The R1 and R2 files with that don't have the five tags identified (e.g. only a few tags or no tags were identified). Hint: You can omit the --unassigned option if you don't care about these unassigned reads files.
* **barcodeids.fq.gz**: The final barcodes (e.g. each SPRITE clusters get a unique final barcode) that's associated with the assigned reads files. The tags associated with each barcode are outputted in **mapping.txt**.

Because we used ``--mod-names``, the tag names will be outputted in the FASTQ header, e.g. as follows:

.. code-block:: text

   @SRR7216015.2::[DPM6A2][NYBot86_Stg][Odd2Bo12][Even2Bo90][Odd2Bo62]
   TGACATGTTTGGCTCTCTGTTTGTCTGTTATTGGTGTAAAAGAATGCTTGTGATTTTTGCACATTGATTTTGTATCCTGAGACTTTGCTGAAGTTGCTTCTGGATGGATTAAATT
   +
   DDDDDIIIIIIIIIIIIIIIIIIIIIIHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIHIIIFHHIIIIIIIIIII


.. hint::

   Add ``--com-names`` option if you want a **numerical** identifier for the SPRITE clusters placed into the FASTQ header comments rather than (or in addition to) the "final barcodes".
   
   If you don't care about "final barcodes", You can omit --outb and --mapping; this will make things faster and more memory efficient.



Ligation Efficiency
^^^^^^^^^^^^^^^^^^^

To assess ligation efficiency, use the script at `ligeff.sh <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/sprite/ligeff.sh>`_


.. code-block:: shell

   ./ligeff.sh SRR7216015_o1.fastq.gz SRR7216015_u1.fastq.gz



RD-SPRITE
^^^^^^^^^

Processing RD-SPRITE (RNA-DNA SPRITE) is also possible; see `rdsprite_config.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/sprite/rdsprite_config.txt>`_ for an example.


References
^^^^^^^^^^

The following references, which either describe the method, were posted prior to, or contributed to the development of this tutorial, are acknowledged and credited:

1. Quinodoz SA, Ollikainen N, Tabak B, Palla A, Schmidt JM, Detmar E, Lai MM, Shishkin AA, Bhat P, Takei Y, Trinh V. Higher-order inter-chromosomal hubs shape 3D genome organization in the nucleus. Cell. 2018 Jul 26;174(3):744-57. `https://doi.org/10.1016/j.cell.2018.05.024 <https://doi.org/10.1016/j.cell.2018.05.024>`_

2. Quinodoz SA, Bhat P, Chovanec P, Jachowicz JW, Ollikainen N, Detmar E, Soehalim E, Guttman M. SPRITE: a genome-wide method for mapping higher-order 3D interactions in the nucleus using combinatorial split-and-pool barcoding. Nature protocols. 2022 Jan;17(1):36-75. `https://doi.org/10.1038/s41596-021-00633-y <https://doi.org/10.1038/s41596-021-00633-y>`_

3. `SPRITE pipeline wiki <https://github.com/GuttmanLab/sprite-pipeline/wiki>`_


