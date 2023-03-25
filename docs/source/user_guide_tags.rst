.. _Tags guide:

User guide: Tags
================

Tags and their associated sequences that you want to identify can be specified in the **config file table**.

Tags and IDs
^^^^^^^^^^^^

In the **tags** column of the config file table, you enter either a sequence or the path to a file containing a list of sequences. When specifying a file name, you can either specify it as ``file.txt`` (in which case all sequences in the file get the same tag ID) or as ``file.txt$`` (in which case all sequences in the file get a different tag ID).

In the **ids** column of the config file table, you enter either a tag name or identifier that will be used to reference the tag sequences associated with this tag.

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
   
   Additionally, the initiator and terminator policy applies to each file *individually*. Say we have paired-end reads (e.g. ``--nFastqs=2``) if a terminator is found in file #0, we'll stop our search in file #0 but we'll begin anew in file #1.
