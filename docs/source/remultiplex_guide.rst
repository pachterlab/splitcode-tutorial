Remultiplexing
==============

What if you have a set of FASTQ files where each FASTQ file (or FASTQ file pair) is a single cell? This can be difficult to feed into programs that expect barcodes to be associated with each cell rather than having each cell be in a separate file.

Therefore, splitcode has a remultiplexing option where you can simply supply a batch file containing all the individual FASTQ files and splitcode will assign "fake" barcodes for each file supplied.

To do this, first create a ``batch.txt`` file as follows:

.. code-block:: text

 todo

