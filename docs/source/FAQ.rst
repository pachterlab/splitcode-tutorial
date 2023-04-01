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

If we have two sequences ``AAGA`` and ``AAGAT`` in your config file, the matching sequence will be ``AAGAT`` because it's the longer sequence in the read. Therefore, all operations (extraction, substitution, etc.) will be done with respect to ``AAGAT``. Note: In this example, those two sequences **must** have the **same tag ID** otherwise neither will match since technically a collision has occurred (i.e. both sequences are possible matches). See :ref:`Sequences same tag question`.

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

.. _CL questions:

Command-line questions
----------------------

.. _CL assign question:

When should I use --assign when running splitcode?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should use the ``--assign`` option whenever you want to create a unique identifier (i.e. a 16-bp **final barcode**) for each permutation of tags identified (i.e. when the tags identified and the order in which they are identified is important). For example, if you want ``tag_A,tag_B,tag_C`` to get an ID and ``tag_A,tag_C,tag_B`` to get another ID and ``tag_B,tag_B,tag_A`` to get another ID, then use ``--assign``. This is especially useful for complex technical sequences with many components, such as those from split-pool assays with many rounds of split-pooling.

A second reason to use ``--assign`` is if you want only certain reads that meet a *tag condition* to be outputted. This means that all reads that **don't meet the minFinds/minFindsG** criteria (i.e. aren't found the minimum number of times specified) or have **zero tags identified** will be considered **unassigned**. Those unassigned reads can be written to separate output files via the ``--unassigned`` option. If the ``--assign`` option is *not* specified, those unassigned reads will still be outputted as normal with the rest of the output.

.. hint::

   If you want to exclude a tag from being considered in forming the **final barcode**, then set the value ``1`` for that tag in the ``exclude`` column of the config file.

.. _output final barcodes question:

How do I specify the output of the final barcodes?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The **final barcodes** obtained by ``--assign`` (see above) can be outputted in several ways.

* ``--outb``: Use this option to specify an output filename where you want the final barcode sequences to be outputted in FASTQ format.
* ``--pipe``: Use this option to interleave the final barcode sequences as the first sequence in each read when writing output to standard output.
* ``--no-outb``: Use this option to not output the final barcode sequences at all.
* ``--com-names``: Use this option to include a numerical ID representing the final barcode into the header of each FASTQ read (i.e. in the "read name" row of each read). IDs will be formatted in **SAM tag** format like ``SI:i:0``, ``SI:i:1``, ``SI:i:2``, etc. because many downstream tools can process SAM tags included in FASTQ read headers. The numerical ID corresponds precisely to the line number (zero-indexed) of the **mapping file**.
* Default: When neither ``--outb`` nor ``--no-outb`` are specified, the final barcode sequences are simply prepended to the reads of the first output FASTQ file.

The **mapping file** (to map between final barcodes and the tags that form it) is specified via the ``--mapping`` option. The final barcodes will always be sorted in the same order in each run (i.e. AAAAAAAAAAAAAAAA is always the first final barcode, AAAAAAAAAAAAAAAT is always the second final barcode, etc.). Therefore, when using numerical IDs via ``--com-names``, you know that ``SI:i:0`` will always be ``AAAAAAAAAAAAAAAA``.
   

How do I specify multiple FASTQ files to be processed at once?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify multiple FASTQ files on the command-line via the ``--nFastqs`` option. If you set ``--nFastqs=2`` (which is what you want to do for paired-end reads), both read pairs will be processed together. If you set that and supply 6 FASTQ files, the first two FASTQ files will be processed together as a pair, then the next 2 FASTQ files will be processed together as a pair, followed by the final 2 FASTQ files. You can also set ``--nFastqs`` to be a number greater than 2; for instance, if you have I1 and I2 indices and R1 and R2 reads that you want all processed as a single read set, you can simply set ``--nFastqs=4``.


.. _GUI questions:

GUI questions
-------------


Why does the GUI produce empty output when I click run even though I know my entered sequence should result in some output?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The most common cause of this issue is that the input you entered is not in FASTQ format. Each sequence in your input must consist of four lines exactly in FASTQ format. This also means **your quality scores MUST be of the same length as the sequence**. When playing around with different sequences, make absolutely sure you adjust the length of the quality scores line as well.


General questions
-----------------


Can splitcode discover what adapter sequences are within the data?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

No. While splitcode is designed to detect and trim sequences defined in the config file, splitcode cannot discover unspecified sequences. For this task, there are many other tools that can do so (see the splitcode paper which references many such tools).


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



How can I optimize splitcode's performance?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* **Location restriction**: splitcode scans each read from beginning to end within the locations specified in the config file in order to find tags. If no location is specified, splitcode will scan each read from beginning to end. Thus, by restricting the scanning to only locations within a read where a tag might be identified, splitcode's runtime will greatly improve. For example, if you have 200 bp long reads but all your tag sequences are within the first 30 bp's, you should specify that in the ``locations`` column for each tag in the config file.
* **Partial sequence matching**: If you have a tag that is a very long sequence, there might be no need to try to match that entire sequence. Instead, consider matching only part of the sequence.
* **Less error tolerance**: Related to the previous question, in most cases, there's no reason to specify an error tolerance greater than 2 hamming distance mismatches. The lesser the error tolerance, the better splitcode will perform.
* **Minimize output**: Minimize what you need outputted. For example, if you supply four FASTQ files but only need the second and third one outputted, you can use ``--select=1,2`` (zero-indexed) to output only those files. Moreover, specify trimming options such as ``--left``, ``--right``, ``--trim-5``, ``--trim-3``, in order to trim what you output.
* **Streaming rather than writing to disk**: Rather than writing FASTQ files or gzip'd FASTQ files to disk, simply use ``--pipe`` to direct splitcode's output to standard output, and direct that output to downstream tools via `pipelines <https://www.gnu.org/software/bash/manual/bash.html#Pipelines>`_ or process substitutions `process substitutions <https://www.gnu.org/software/bash/manual/bash.html#Process-Substitution>`_.

.. seealso::

   :ref:`interleave page`
     More information about streaming output.

