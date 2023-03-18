Getting started
===============

Installation
^^^^^^^^^^^^
To use splitcode, first install it from source:

.. code-block:: shell

  git clone https://github.com/pachterlab/splitcode
  cd splitcode
  mkdir build
  cd build
  cmake .. -DZLIBNG=ON
  make
  make install


Graphical User Interface (GUI)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To use splitcode's GUI, please visit `https://pachterlab.github.io/splitcode/ <https://pachterlab.github.io/splitcode/>`_

.. note::

   This GUI is under development and is a work in progress.



Command-line structure
^^^^^^^^^^^^^^^^^^^^^^
The command-line structure for running splitcode is as follows:

.. code-block:: shell

  splitcode [arguments] fastq-files

A list of options can be viewed by running ``splitcode -h``.

The arguments you supply give splitcode instructions on what to do with your FASTQ files. Most often, you'd want to supply a config file to splitcode, specifying how you want your reads to be processed. You'd also want to supply an output option.


Overview
^^^^^^^^

Tags
~~~~

splitcode is organized such that ``tags``, the technical sequences that can be identified in reads, are supplied in a tab-separated value ``config file`` by the user. The rows of the config file contain the user-supplied ``sequences`` while the columns of the config file describe the properties of each sequence. Each sequence is associated with a tag via a tag ID and multiple sequences can be associated with the same tag ID (e.g. if you want to treat AAAA and TTTT as the same, you can give the same tag ID). Each row of the config file describes a tag and each column of the config file is for a certain property of the tag (e.g. tag ID, tag sequence, error tolerance, tag group, etc. all comprise the columns). splitcode identifies tags within sequencing reads by scanning each read from beginning to end.

Note about difference between having sequences be part of the same tag or having each sequence be part of a different tag: For sequences belonging to the same tag, if any of those sequences are found in a read, splitcode considers that tag identified and moves on. On the other hand, if a sequence mapped to a tag is also found in another tag (i.e. one with a different tag ID), and splitcode encounters that sequence while scanning through a read, splitcode will determine that a "collision" has occurred and just move on without identifying either tag. If AAAA and TTTT are associated with the same tag and we encounter AAAA in a read, splitcode will identify AAAA. However, if we add in another tag that where one of the sequences associated with that tag is AAAA, then if we find AAAA in a sequence, splitcode won't identify that sequence. This is why the former case is good for error tolerant matching whereas the latter case is good for demultiplexing based on oligos (if both AAAA and AAGG are in a on-list and we allow hamming distance 1 mismatch, we don't want to match AAAG because that's one hamming distance away from each sequence).

In summary: The ``config file`` contains ``sequences`` which are organized into ``tags``, which are in turn organized into ``tag groups``.

Barcodes
~~~~~~~~

A permutation of tags identified within a read forms a unique ``barcode``. This generated barcode can thus be used to demultiplex reads based on the identified tags. This barcode is 16 base pairs in length and supplying ``--mapping=mapfile.txt`` will output a file named mapfile.txt that maps the generated barcode with the tags (and their order).

Extraction
~~~~~~~~~~



Output
~~~~~~



Basic usage
^^^^^^^^^^^

Here, we demonstrate a basic usage example of splitcode where we search for the sequence ATCG and replace it with TTTT.

First, create a config file named ``config.txt`` with the following contents:

::

 ids tags subs
 id1 ATCG TTTT

Next, let's create a sample FASTQ file called ``intro.fastq`` with the following contents:

::

 @read1
 GGGATCGCCC
 +
 !!!!!!!!!!
 @read2
 ATCGTTTTTT
 +
 !!!!!!!!!!


Then, run the following: 

.. code-block:: shell

  splitcode -c config.txt --nFastqs=1 --pipe intro.fastq
  
The resulting output will be as follows:

::

 @read1
 GGGTTTTCCC
 +
 !!!KKKK!!!
 @read2
 TTTTTTTTTT
 +
 KKKK!!!!!!

As you can see from the output, the sequence ATCG has been replaced with TTTT. Also note that the quality scores are set to ``K`` -- every new nucleotide that splitcode inserts will always have this quality score. The ``--nFastqs=1`` argument means that we're only considering one FASTQ file as part of a set of reads. If we had two FASTQ files as part of our set of reads (as is the case with paired-end reads), we'd set that value to 2. The ``--pipe`` argument means that we're writing the results directly to standard output. If we wanted to write to a file called output.fastq, we would not use that argument; instead, we would supply ``-o output.fastq``.

