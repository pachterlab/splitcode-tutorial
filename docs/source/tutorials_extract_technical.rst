.. _Extraction guide:

Put technical sequences into separate files
===========================================

Separating based on location
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's say we have barcodes, UMIs, and the biological sequence at specified locations. For example, 10X (version 3) chemistry has the following format:

* Barcode (16 bp): File 0 (R1.fastq.gz), position 0 to 16
* UMI (12 bp): File 0 (R1.fastq.gz), position 16-28
* cDNA: File 1 (R2.fastq.gz), entire read

We can extract into separate files as follows:

.. code-block:: text

   splitcode -x "0:0<barcode>0:16,0:16<umi>0:28,1:0<cdna>1:-1" --x-only --nFastqs=2 --gzip R1.fastq.gz R2.fastq.gz

Three files will be generated: ``barcode.fastq.gz``, ``umi.fastq.gz``, ``cdna.fastq.gz``

.. note::

   Note that quality scores will NOT be preserved (all quality scores will be replaced with K).
   
   Also note that in lieu of a ``config.txt`` file, we supplied the extraction pattern on the command line using ``-x`` (although we could use a config file with just one line containing the extraction string preceded by ``@extract``).

Separating based on tag identification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's revisit the :ref:`example<example page>`, where, for ``R1.fastq``, we have a 5-bp Barcode A, followed by a variable length region (region 1), followed by a 5-bp/6-bp barcode B, followed by an 8-bp UMI 3-bp's after barcode B, followed by a variable length region (region 2) that procedes until the end of the read. For ``R2.fastq``, the entire sequence is the cDNA sequence (except the last 4 bp's are trimmed).

We want to extract the barcodes, the UMI, region 1+2, and the cDNA into separate files.

Here, we'll create the following ``config.txt`` file:

.. code-block:: text

   @extract <barcode_A{{@grp_A}}>,<barcode_B{{@grp_B}}>,{{grp_B}}3<umi[8]>,{{grp_A}}<region_1>{{grp_B}},{{grp_B}}3<region_2>0:-1,1:0<cdna>1:-1
   @trim-3 0,4
   groups	ids           tags    distances	  next		  maxFindsG	locations
   grp_A	Barcode_A1	  AAGGA   1		        {{grp_B}} 1		      0:0:5
   grp_A	Barcode_A2	  GTGTG   1		        {{grp_B}} 1		      0:0:5
   grp_A	Barcode_A3	  CGTAT   1		        {{grp_B}} 1		      0:0:5
   grp_B	Barcode_B1	  GCGCAA  0		        -		      1		      0:5:100
   grp_B	Barcode_B2	  CCCGT   0           -		      1		      0:5:100

We can extract into separate files as follows:

.. code-block:: text

   splitcode -c config.txt --x-only --nFastqs=2 --gzip R1.fastq R2.fastq


Six files will be generated:

* ``barcode_A.fastq.gz``
* ``barcode_B.fastq.gz``
* ``umi.fastq.gz``
* ``region_1.fastq.gz``
* ``region_2.fastq.gz``
* ``cdna.fastq.gz``

