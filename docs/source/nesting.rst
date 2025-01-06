.. _Nesting guide:


Nesting config files
====================

Introduction
------------

Sometimes, you might want to perform operations on sequences that have been extracted, modified, or corrected with splitcode (i.e. go through another round of splitcoding). For example, one might want to extract sequences then correct them.

This is possible by using a nested config file. Essentially, simply place ``@nest`` at the bottom of your config file and add config options after it.



A simple example
----------------


Say we have the following FASTQ file (input.fastq):

.. code-block:: text

   @read
   AAATTTTGGGGG
   +
   KKKKKKKKKKKK


Let's say we want to replace the **AAA** at the beginning with **GGGGG** and then, in a second step, replace **GGGGG** with **CCC**. In other words the sequence goes from **AAATTTTGGGGG** to **GGGGGTTTTGGGGG** to **CCCTTTTCCC**. We would specify the following config file (config.txt):


.. code-block:: text

   ids	tags	subs
   X	AAA	GGGGG

   @nest

   ids	tags	subs
   Y	GGGGG	CCC



When we run the following command:

.. code-block:: text

   splitcode -c config.txt --pipe input.fastq


THe following will be printed out:


.. code-block:: text

   @read
   CCCTTTTCCC
   +
   KKKKKKKKKK



An extraction example
---------------------

OK, we'll use the same input.fastq as the previous example, where the sample read sequence is **AAATTTTGGGGG**.

.. code-block:: text
  :caption: input.fastq

   @read
   AAATTTTGGGGG
   +
   KKKKKKKKKKKK


Let's say we want to do the following operations: 1) Extract 4 bp's after encountering AAA, 2) Error-correct the extracted sequence to the following scheme (AAAA becomes TTT; TTTT becomes AAA; CCCC becomes GGG; GGGG becomes CCC). We set up the following config.txt file:


.. code-block:: text


   @extract {X}<extracted_seq[4]>

   ids	tags	subs
   X	AAA	GGGGG

   @nest

   ids	tags	subs	locations
   Y1	AAAA	TTT	0
   Y2	TTTT	AAA	0
   Y3	CCCC	GGG	0
   Y4	GGGG	CCC	0


OK, we set ``locations`` to be ``0``. Why? Because of ``@nest``, at the next level, the extracted sequence will become file #0 and the input read will become file #1. 



So, when we run: 

.. code-block:: text

   splitcode -c config.txt -o out_R1.fq,out_R2.fq input.fastq


We'll get the following outputs:


.. code-block:: text
  :caption: out_R1.fq

   @read
   CCC
   +
   KKK


.. code-block:: text
  :caption: out_R2.fq

   @read
   GGGGGTTTTGGGGG
   +
   KKKKKKKKKKKKKK


Note that we specified two output files because, again, due to ``@nest``, at the next level, the extracted sequence (from the first level) became file #0 and the input read became file #1.



