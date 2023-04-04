Remultiplexing
==============

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