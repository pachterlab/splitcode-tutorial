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

.. _Tag priority question:

How does splitcode prioritize what the matching sequence is?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The matching sequence is prioritized by length (with longest sequence getting the highest priority).

Let's say we have a FASTQ file as follows:

::

 @read1
 AAAAAAAAGATTTT
 +
 !!!!!!!!!!!!!!

If we have two sequences ``AAGA`` and ``AAGAT`` in your config file, the matching sequence will be ``AAGAT`` because it's the longer sequence in the read. Therefore, all operations (extraction, substitution, etc.) will be done with respect to ``AAGAT`` and identified tag will be the tag that is associated with ``AAGAT``.

Furthermore, splitcode operates by scanning reads from beginning to end (i.e. from left to right) therefore if two sequences overlap slightly, the left-most sequence will get priority.

.. tip::

  It's always good to realize that splitcode scans sequences from beginning to end. If we have two sequences **AAGAT** and **ATTTT** for the FASTQ read above, it's impossible for the latter sequence to be identified. splitcode will identify AAGAT and then move on past those 5 bp's, but the remaining bp's are TTT so there's no way for ATTTT to be found.
  
  
   
.. _Config file questions:

Config file questions
---------------------

.. _Empty question:

How to denote an empty value in the config file?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The value ``-`` denotes an empty value. For example, in the **next** column, not every tag will necessarily require a "next" entry to be populated (some tags, when identified, may not require splitcode to search for specific tag or group next). Therefore, for those rows, in the "next" column, simply enter ``-``. 

   
.. _Performance questions:

Performance questions
---------------------

.. _Error tolerance performance question:

Why is there a slowdown and high memory usage when I increase the error tolerance?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

splitcode is optimized for finding relatively small sequences (<40 bp's) with few mismatches (hamming distance ≤ 3). Each sequence and all its associated mismatches are indexed therefore a large sequence with many mismatches will naturally decrease the performance of splitcode and could make it computationally intractable to use splitcode under such configurations.

Given that there are 5 bases (A, T, C, G, N), and let L be the sequence length and M be the number of mismatches allowable, the computationally complexity of splitcode scales to the number of mismatches for a certain sequence length which is as follows:

.. math::

  (5-1)^M\binom{L}{M}


