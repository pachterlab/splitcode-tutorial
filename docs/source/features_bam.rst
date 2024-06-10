BAM output
==========

The output of ``splitcode`` can be in the form of BAM files (`Li, Handsaker, et al., Bioinformatics 2009 <https://doi.org/10.1093/bioinformatics/btp352>`_). These *unaligned* BAM files are convenient for storing the output sequences along with the metadata associated with tag identification.

To output a BAM file, run splitcode with the ``-out-bam`` option, along with options such as ``--com-names``, ``--seq-names``, ``-loc-names``, and ``-bc-names``.

An example BAM output (as viewed with `samtools <https://www.htslib.org/>`_)), would look like:

.. code-block:: text

 read1	12	*	0	0	*	*	0	0	CCCCCCCCCGGGCCCCCCCCCGGGAACCTAG	KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK	CB:Z:CCCCCCCGGCCCCCCCGG	BI:i:0	BC:Z:AAAAAAAAAAAAAAAA	LX:Z:tag1:0,0-7,tag2:0,9-11,tag1:0,12-19,tag2:0,21-23
 read2	12	*	0	0	*	*	0	0	CCCCCCCCCGGGCCCCCCCCCGGGAACCTAG	KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK	CB:Z:CCCCCCCGGCCCCCCCGG	BI:i:0	BC:Z:AAAAAAAAAAAAAAAA	LX:Z:tag1:0,0-7,tag2:0,9-11,tag1:0,12-19,tag2:0,21-23

