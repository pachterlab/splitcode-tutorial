.. _Read names guide:


Extracting from read names
==========================


Sometimes, sample barcodes and UMIs are incorporated into the read name of a FASTQ header (such that the header contains the read ID followed by a whitespace followed by the barcode/UMI information). We can extract these using the ``from-name`` option.

Let's say you have a FASTQ file (input.fastq) where a read looks like:

.. code-block:: text

  @readID1 1:N:ATCCC+ATCG
  GGGGAGAGAGCGATAGACATA
  +
  JJJJJJJJJJJJJJJJJJJJJ

As you can see, there are two sequences in the read name (ATCCC and ATCG). We can extract this by putting the following at the beginning of the config file:


.. code-block:: text

  @from-name 0,0,0,::;0,0,0,::+


The ``from-name`` expression is formatted as ``location,pattern`` (and you can specify multiple of them separated by semicolons). The location string is formatted as: input file number, output file number, output position. So, above, we have the first expression **0,0,0,::** which means input file #0 (the input file number that we're doing the read name extraction on), output file #0 (the output file number that the extracted sequence will be placed in), and output position 0 (we are going to put the extracted sequence at the beginning, i.e. position 0). The pattern ``::`` means we're going to go into the read name (starting after the first whitespace) and extract the sequence after the first two colons (i.e. ATCCC) -- the extraction stops when the next non-ATCGN character is encountered (i.e. +). The second expression **0,0,0,::+** is the same except for the pattern ``::+`` means we extract after the first two colons and a plus symbol (i.e. ATCG). Note: Since both expressions say place the output at position 0, the two sequences will be stitched together and placed at the beginning of the read (i.e. the read will become ATCCCATCGGGGGAGAGAGCGATAGACATA).

You can alternately simply specify ``from-name`` on the command-line by doing:

.. code-block:: text

  splitcode --from-name="0,0,0,::;0,0,0,::+" [other options] input.fastq


If one wishes to use the ``@extract`` mechanism to extract the sequences from the read names, one should put ``-1`` as the value of the output position. Here's what the beginning of the config file will look like here:


.. code-block:: text

  @from-name 0,0,-1,::;0,0,-1,::+
  @extract <barcode{:}>,<umi{:}>


The resulting barcodes will then be written into a barcode.fastq file and umi.fastq file. If you want them to be written to a single barcode.fastq file file, you can simply do ``@extract <barcode{:}>,<barcode{:}>``. The first ``{:}`` refers to the first read name expression (i.e. the ATCCC) while the second ``{:}`` refers to the second read name expression (i.e. ATCG).




