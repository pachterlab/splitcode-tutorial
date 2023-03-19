Frequently asked questions
==========================

.. contents::
   :local:
   
.. _Tag questions:

Tag identification questions
----------------------------

.. _Sequences same tag question:

What is the difference between multiple sequences being part of the same tag and each sequence being part of a different tag?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For sequences belonging to the same tag, if any of those sequences are found in a read, splitcode considers that tag identified and moves on. On the other hand, if a sequence mapped to a tag is also found in another tag (i.e. one with a different tag ID), and splitcode encounters that sequence while scanning through a read, splitcode will determine that a "collision" has occurred and just move on without identifying either tag. 

Consider the following two cases:

.. list-table:: Case 1
   :widths: 25 50 25
   :header-rows: 1

   * - ids
     - tags
     - distances
   * - tagA
     - AAAAAAAA
     - 1
   * - tagA
     - AAAAAAGG
     - 1

.. list-table:: Case 2
   :widths: 25 50 25
   :header-rows: 1

   * - ids
     - tags
     - distances
   * - tagA
     - AAAAAAAA
     - 1
   * - tagB
     - AAAAAAGG
     - 1

Let's say we have a FASTQ file as follows:

::

 @read1
 AAAAAAAAGATTTT
 +
 !!!!!!!!!!!!!!

* **Case 1**: Since AAAAAAAA and AAAAAAGG are associated with the *same* tag and we allow a hamming distance 1 mismatch (which the sequence AAAAAAAAGA falls within), **tagA will be identified**. This is useful when we care about matching any one of multiple sequences.

* **Case 2**: Since AAAAAAAA and AAAAAAGG are associated with *different* tags and we allow a hamming distance 1 mismatch, the sequence AAAAAAAAGA can be associated with both tagA and tagB, hence a collision between two different tags has occurred. As a result, splitcode will simply move on and **neither tagA nor tagB will be identified**. This is useful when a library has a barcode list of many sequences (as in scRNA-seq) and we want to sort out the reads based on barcodes (since each barcode could represent an individual cell in scRNA-seq). If there's a collision, you can't resolve which barcode in the on-list the sequence corresponds to, so tag identification can't occur.

For information on how to supply a list of sequences in a file either giving each sequence the same tag ID or a different tag ID, see the next question.

.. _Sequences external file question:

How do I supply a list of sequences from an external file in the config file?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Simply enter the path to file in lieu of an actual sequence. Say we have a file named ``list.txt`` containing dozens of sequences. You can choose to either give each sequence the same tag ID or to give each sequence a unique tag ID. In the latter case, append a ``$`` to the end of the path (this is probably what you want to do for demultiplexing reads into individual cells in single-cell RNAseq given a barcode list). See below.

.. list-table:: Each sequence in list gets the same tag ID
   :widths: 25 50 25
   :header-rows: 1

   * - ids
     - tags
     - distances
   * - tagA
     - list.txt
     - 1

For the above, each sequence in ``list.txt`` gets assigned the tag ID: **tagA**.

.. list-table:: Each sequence in list gets a different tag ID
   :widths: 25 50 25
   :header-rows: 1

   * - ids
     - tags
     - distances
   * - tagA
     - list.txt$
     - 1

For the above, each sequence in ``list.txt`` gets assigned tag IDs: **tagA-0**, **tagA-1**, **tagA-2**, **tagA-3**, ...

:ref:`Tag identification questions`.


:ref:`Tag questions`.

.. _Tag priority question:

How does splitcode prioritize what the matching sequence is?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


