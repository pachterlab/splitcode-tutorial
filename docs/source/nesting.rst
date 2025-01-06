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


Let's say we want to do the following operations: 1) Extract 4 bp's after encountering AAA, 2) Error-correct the extracted sequence to the following scheme (AAAA becomes TTT; TTTT becomes GGG; CCCC becomes AAA; GGGG becomes CCC). We set up the following config.txt file:


.. code-block:: text


   @extract {X}<extracted_seq[4]>

   ids	tags
   X	AAA

   @nest

   ids	tags	subs	locations
   Y1	AAAA	TTT	0
   Y2	TTTT	GGG	0
   Y3	CCCC	AAA	0
   Y4	GGGG	CCC	0


OK, we set ``locations`` to be ``0``. Why? Because of ``@nest``, at the next level, the extracted sequence will become file #0 and the input read will become file #1. 



So, when we run: 

.. code-block:: text

   splitcode -c config.txt -o out_R1.fq,out_R2.fq input.fastq


We'll get the following outputs:


.. code-block:: text
  :caption: out_R1.fq

   @read
   GGG
   +
   KKK


.. code-block:: text
  :caption: out_R2.fq

   @read
   AAATTTTGGGGG
   +
   KKKKKKKKKKKK


Note that we specified two output files because, again, due to ``@nest``, at the next level, the extracted sequence (from the first level) became file #0 and the input read became file #1.


Error-correcting extracted sequences to a list of barcodes
----------------------------------------------------------

OK, building off the above, let's reuse the input.fastq read sequence file:


.. code-block:: text
  :caption: input.fastq

   @read
   AAATTTTGGGGG
   +
   KKKKKKKKKKKK



Let's say we have the following barcodes list (b.txt):

.. code-block:: text
  :caption: b.txt

   ATAT
   TCGA
   GAGG
   TATT


And let's set the following config file, allowing for one mismatch via the ``distances`` column, and correcting it to its original sequence via the ``.`` value in ``subs``. We provide ``b.txt$`` (with the ``$`` after the file name to specify that each sequence in that file should be its own unique tag).


.. code-block:: text


   @extract {X}<extracted_seq[4]>

   ids	tags	subs
   X	AAA	GGGGG

   @nest

   ids	tags	subs	locations	distances
   Y	b.txt$	.	0	1



So, when we run: 

.. code-block:: text

   splitcode -c config.txt -o out_R1.fq,out_R2.fq input.fastq



We'll get the following outputs:


.. code-block:: text
  :caption: out_R1.fq

   @read
   TATT
   +
   KKK


.. code-block:: text
  :caption: out_R2.fq

   @read
   AAATTTTGGGGG
   +
   KKKKKKKKKKKK


As you can see the **TTTT** that was extracted from input.fastq was corrected (via one hamming distance) to **TATT**.

You can do other stuff too, e.g. if you set ``minFinds`` to 1, the extracted sequences that did not match anything in ``b.txt`` will not be outputted.



