.. _Tags guide:

User guide: Tags
================

Tags and their associated sequences that you want to identify can be specified in the **config file table**.

Specifying Tags
^^^^^^^^^^^^^^^

In the **tags** column of the config file table, you enter either a sequence or the path to a file containing a list of sequences. When specifying a file name, you can either specify it as ``file.txt`` (in which case all sequences in the file get the same tag ID) or as ``file.txt$`` (in which case all sequences in the file get a different tag ID).

.. seealso::

   :ref:`Tag questions`
     FAQ about when to use same tag ID vs. different tag IDs for sequences, how to supply sequences stored in an external file, and how does splitcode prioritize which sequence in a read to identify when there are multiple possibilities.

Initiator and Terminator Sequences
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For sequences supplied in the **tags** column, you can also specify whether that sequence is an **initiator** or **terminator** sequence.

* **initiator**: To specify an initiator sequence, prefix the tag sequence with an asterick like ``*ATCG``. This means that no other sequences will be identified until this sequence is.

* **terminator**: To specify a terminator sequence, suffix the tag sequence with an asterick like ``ATCG*``. This means that once we've identified this sequence, we'll immediately stop our search for other tags.

.. hint::

   Multiple sequences (whether of the same tag ID or of different tag IDs) can be initiators or terminators, you can have an entire file of sequences be initiators or terminators by using the same notation (e.g. ``file.txt*``), and a sequence can be both an initiator and terminator (e.g. ``*ATCG*``).
   
   Additionally, by default, the initiator and terminator policy applies to each file *individually*. Say we have paired-end reads (e.g. ``--nFastqs=2``) if a terminator is found in file #0, we'll stop our search in file #0 but we'll begin anew in file #1.


Minimum Finds and Maximum Finds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**minFindsG** column: You can enter the minimum number of times a group must be found. If this isn't met, then the read is considered **unassigned** which means if we specify ``--assign`` on the command line, the read won't be outputted nor will it be assigned a final barcode (if we specify files in the ``--unassigned`` option, those reads will be written there).

**minFinds** column: You can enter the minimum number of times a tag must be found. If this isn't met, then the read is considered **unassigned**.


.. seealso::

   :ref:`CL assign question`
     FAQ about how assigned/unassigned works in splitcode.

**maxFindsG** column: You can enter the maximum number of times a group can be found. Once this max number is met, splitcode will no longer identify the group. Unlike minimimum finds, this does **not** cause a read to go unassigned; rather, splitcode will simply stop identifying the group for which this max number has been met.

**maxFinds** column: You can enter the maximum number of times a tag can be found. Once this max number is met, splitcode will no longer identify the tag with the given tag ID.


Substitutions
^^^^^^^^^^^^^

**subs** column: You can specify what you want to replace a tag sequence with upon identifying it in a read. The read in the output FASTQ will therefore be edited to contain the specified replacement.

Standard replacements: You can simply replace a sequence with another sequence; for example, you can replace ``ATCG`` in a read with ``NNN`` by specifying NNN in the subs column for the tag with the ATCG sequence.

Error-correction replacements:  If you put the value ``.`` in the column, then that means replacing the tag sequence with the original sequence. An example of what this means: if you have the sequence ``AAA`` (and allow for one substitution error by putting the value ``1`` into the **distances** column) and put ``.`` in the **subs** column, identifying ``ATA`` in a read will cause the ATA to be replaced with AAA in the output. This is especially useful for error correction (e.g. correcting to a list of barcodes).


Next and Previous
^^^^^^^^^^^^^^^^^

**next** column: Specify the next tag or group that you want to search for next (after identifying the current tag); splitcode will *only* search for that specified tag or group and will not find any other tags. Enclose tag IDs in single curly brackets, e.g. ``{tag_A}``, and enclose group names in double curly brackets, e.g. ``{{group_A}}``. You can specify *spacers*, for example, ``{{group_A}}3`` means that, although splitcode will only search for group_A, it will not successfully identify a group_A tag unless there exists at least 3 bps between the end of the current tag and the group_A tag. You can also specify ``{{group_A}}3-5`` which means there must exist at least 3 bps but no more than 5 bps between the end of the current tag and the group_A tag.

**previous** column: Similar to the *next* column, except here, the current tag will not be identified unless the most recent tag or group identified is the one specified in this column. Like above, use single curly brackets for tag IDs and double curly brackets for group names. Like above, you can specify *spacers*, e.g. ``{{group_A}}3-5`` here would mean that the current tag will not be identified unless there exists at least 3 bps but no more than 5 bps between the end of the previous tag and the start of the current tag.

.. hint::
   
   By default, the next and previous policy applies to each file *individually*. Say we have paired-end reads (e.g. ``--nFastqs=2``), if we're searching for a "next" tag in file #0 but don't find it, we won't continue with trying to find "next" tag in file #1; rather we'll begin anew (i.e. the "next" from file #0 doesn't apply to file #1).


Left and Right Trimming
^^^^^^^^^^^^^^^^^^^^^^^

**left** column: Specify whether you want to trim from the left by entering ``1`` into this column (or ``0`` if you don't want to trim). The associated tag will be trimmed from the left such that, when the tag is identified, the tag sequence AND everything to the *left* of the tag will be trimmed off (i.e. only stuff to the right of the tag will remain). You can also specify how many extra bps you want to trim by entering a number after the ``1`` -- e.g. entering ``1:3`` means that we want to additionally remove the next 3 values to the *right* of the end of the tag and ``1:-3`` means that we want to remove the next 3 bps to the *left* of the end of the tag. For example, if we have ``CCAAAAATTTGGGGGCC`` and the tag we want to identify has the sequence ``TTT``, trimming from the left (i.e. ``1``) will result in ``GGGGGCC``, trimming with ``1:3`` will result in ``GGCC``, and trimming with ``1:-4`` will result in ``ATTTGGGGGCC`` (i.e. we consider the end of TTT and move left 4 bps, and trim everything to the left of that).

**right** column: Same as the *left* column except we specify trimming from the right. In the case of the ``CCAAAAATTTGGGGGCC`` sequence, specifying ``1`` will result in ``CCAAAAA`` (i.e. removal of the tag and everything to the right of it), specifying ``1:3`` will result in ``CCAA`` (trim an additional 3 bps to the left of the tag), and specifying ``1:-4`` will result in ``CCAAAAATTTG`` (consider the beginning of the tag, move right 4 bps, and trim everything to the right of that).


.. hint::
   
   * If we go over the bounds of the read, we simply trim up to the bounds of the read.
   
   * If multiple trimming possibilities are possible, only the final identified tag (with trimming enabled) will be considered for trimming in the case of **left** or only the first identified tag (with trimming enabled) will be considered for trimming in the case of **right**.
   
   * Both left and right trimming can be enabled for different tags, in which the same rules still apply. For example, specifying left trimming of **AAA** and right trimming of **TTT** for **CCAAAAATTTGGGGGCC**, we'll get **AA** (i.e. TTTGGGGGCC and CCAAA are both trimmed off).

Homopolymer identification
^^^^^^^^^^^^^^^^^^^^^^^^^^

Homopolymers are repeats of a single nucleotide (e.g. GGGGGGGGGG is a 10 bp homopolymer). We can detect these with splitcode by specifying such sequences in the **tags** column. For example, to detect a homopolymer of G's at least 10 bps in length up through 100 bps in length, specify the tag sequence as ``G:10:100``. You can use the other columns (e.g. left, right, subs, etc.) to decide what to do with the detected homopolymer (trim it? replace it something else? etc.).

Error distances/tolerance
^^^^^^^^^^^^^^^^^^^^^^^^^

**distances** column: For tag sequences, you can specify the number of allowable mismatches. Setting ``1`` in the distances column means one substitution is permitted, setting ``2`` means two substitutions are permitted, etc. You can also specify the number of allowable indels and allowable total errors as **allowable_substitutions:allowable_indels:allowable_total_errors**. For example, ``1:1:1`` means one substitution is permitted, one indel is permitted, and a total of one substitution+indel is permitted (i.e. we can have one substitution OR one indel). 

.. warning::
   
   * Do not set the number of allowable errors too high for long sequences otherwise splitcode cannot handle it in terms of memory/time. The purpose of splitcode is not to handle long sequences with more than a couple of errors. Having two or fewer total errors should be sufficient for most applications that splitcode is designed for. See the FAQ:

   :ref:`Error tolerance performance question`

   * Be careful when using indels, e.g. the matched sequence might include extra bps at the beginning since those might technically count as "insertions"  (since splitcode proceeds from the beginning to the end of a read to find matches).

Locations
^^^^^^^^^

**locations** column: You can specify the location where the tag must be found within. The structure of the locations is **file:start:end**. For example ``0:0:10`` means the tag must be contained within the first 10 bps of the read in the first file (**file** = 0; **start** = 0; **end** = 10). Set the **end** to be 0, if you want to extend to the end of the read; for example ``0:5:0`` means the tag can be found anywhere after the first 5 bps of the read in the first file. Additionally, you can set **start** to be a *negative number* to specify proceeding from the end of a read; for example, ``0:-40:0`` means the tag can be found only in the last 40 bps of a read in the first file. FInally, you can set the **file** to be -1 if you want the read to be found in any file.

.. hint::
   
   For simplicity, you can supply fewer than three numbers; e.g. ``1`` is equivalent to ``1:0:0`` and ``1:20`` is equivalent to ``1:20:0``.




Truncated/partial sequences
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's say you expect the sequence ``GAGATGG`` at the beginning of the read. What if this sequence could be partially truncated such that the first couple of bps might be missing? We might instead see **AGATGG** or **GATGG** at the beginning of the read. To account for this, we use partial matching:

**partial5** column: We match truncated sequences at the beginning (5′ end) of the read. In this column, specify the minimum overlap as well as the hamming distance mismatch frequency as **min_overlap:mismatch_frequency**. For example, ``5:0.18`` means a minimum overlap of 5 bps (for the sequence above, either **GAGATGG** **AGATGG** or **GATGG** at the very beginning of the read will match, because the overlap is 5+ bps). With the error frequency of 0.2, that means that the number of substitution errors allowed is 0.2 multipled by the length of the match. For a 7-bp overlap, 0.18 \times 7 = 1.26 = 1 substitution allowed. For a 6-bp overlap, 0.18 \times 6 = 1.08 = 1 substitution allowed. For a 5-bp overlap, 0.2 \times 5 = 0 = 0 substitution allowed. Thus, **CATGG** will not match but **ACATGG** will (in both cases, 1 substitution is present).

**partial3** column: Same as *partial5* except sequences may be truncated at the end at the 3′ end of the read. Like *partial5*, the value entered in the column is supplied as **min_overlap:mismatch_frequency**.

.. warning::
   
   * Do not set the substitution mismatch frequency too high for long sequences otherwise splitcode cannot handle it in terms of memory/time. For a 30-bp sequence, setting a frequency of 0.3 means that 9 substitutions are permitted if the full 30 bps are present at the beginning of the read. This is not what splitcode is designed for: splitcode is designed for identifying short sequences with small number of mismatches (≤3). Programs that implement dynamic programming algorithms like cutadapt can handle high error rates and may be more efficient and more suitable for purposes like adapter trimming depending on your use case. See the FAQ:
   
   :ref:`Error tolerance performance question`


