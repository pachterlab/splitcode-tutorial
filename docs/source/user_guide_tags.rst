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
   
   * Both left and right trimming can be enabled for different tags, in which the same rults still apply. For example, specifying left trimming of **AAA** and right trimming of **TTT** for **CCAAAAATTTGGGGGCC**, we'll get **AA** (i.e. TTTGGGGGCC and CCAAA are both trimmed off).
