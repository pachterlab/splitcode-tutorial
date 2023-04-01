.. _interleave page:

Header and SAM tags
===================

splitcode can put information about identified tags and extracted sequences into the **FASTQ header comments**. The header comments are oftentimes used by downstream programs such as bwa, especially in instances when the downstream program outputs a SAM/BAM file (`Li, Handsaker, et al., Bioinformatics 2009 <https://doi.org/10.1093/bioinformatics/btp352>`_). Below, we list a few of the options to put information into the read header of the splitcode output (you can specify multiple of these options at once). Note that the modified read header will appear in all of splitcode's FASTQ output.

--mod-names
^^^^^^^^^^^

--mod-names is a simple option where the identified tag IDs are appended to the read name in the following format:

``@readname::[tag1][tag2][tag3]``

--seq-names
^^^^^^^^^^^

--seq-names is similar to --mod-names above, except the *sequences* of identified tag IDs are shown (stitched together) in the SAM tag: ``CB:Z:``. For example, if tag1 is AAA, tag2 is TTT, and tag3 is GGG, and we identify each of those tags once in that order (like above), we would get the following for the read header:

``@readname CB:Z:AAATTTGGG``

Of course, if we identify, say tag1, again, we'd get another AAA appended onto that sequence. Also note that even if we allowed error tolerance for a tag, the original sequence (aka the sequence with no errors) specified in the config file, will be the sequence displayed in the CB:Z: tag.

--com-names
^^^^^^^^^^^

--com-names is an option where the numerical final barcode ID is encoded in the SAM tag: ``BI:i:``. When this option is specified, ``--assign`` must be used (to generate the final barcode). As an example, if a read has the final barcode sequence ``AAAAAAAAAAAAACTG``, the SAM tag in the read header would look like:

``@readname BI:i:30``

Since ``30`` is the numerical version of the final barcode sequence ``AAAAAAAAAAAAACTG``. You know this because the mapping file specified in ``--mapping`` has that final barcode sequence on line #30 (zero-indexed; aka the first line would actually be line #0).

.. seealso::

   :ref:`output final barcodes question`
     FAQ about the various options to display the final barcodes.

--x-names
^^^^^^^^^

--x-names is an option where the extracted sequences (specified via ``-x``) are placed in the SAM tag: ``RX:i:``. Multiple extracted sequences of the *same name* will be simply stiched together, and if *multiple extraction names* are given, they are separated by a ``-``. For example, the following might be outputted:

``@readname RX:Z:GATGATGG-ATCC``

.. seealso::

   :ref:`Output extractions guide`
     More information about the output options for extracted sequences.


--sub-assign
^^^^^^^^^^^^

--sub-assign assigns reads to a secondary sequence ID based on a subset of tags present (must be used with ``--assign``). Essentially, like ``--com-names``, a number is given to represent a unique permutation of identified tags. However, here, the unique number is generated based on only a subset of tags. For example, if your config file has four tags, setting ``--sub-assign=0,2`` means only tag #0 and tag #2 will be considered in generating this unique number. Unlike final barcode sequences, this sub-assign command doesn't have a sequence or a mapping file outputted with it -- only a number. The number is stored in the SAM tag ``SI:i`` and may appear as follows:

``@readname SI:i:2``

Generally, you should always use ``--assign`` first and only use ``--sub-assign`` if, for some reason, you need to have another unique identifier generated for a different set of tags.

remultiplex id
^^^^^^^^^^^^^^

The remultiplexing ID is stored in the SAM tag ``BC:Z:``. For more information about remultiplexing, please see the relevant section.

--sam-tags
^^^^^^^^^^

The default SAM tags are ``CB:Z:,RX:Z:,BI:i:,SI:i:,BC:Z:`` for all the use cases discussed previously. What if you want to those default SAM tags? You can use --sam-tags to define a new set of SAM tags, for example:

``--sam-tags="AB:Z:,YZ:Z:,LK:i:,DS:i:,MN:Z:"``

This will replace the default SAM tags (for example, the ``--com-names`` SAM tag will now be ``LK:i:`` instead of ``BI:i:``). You don't even need to use proper SAM tags, you can use whatever characters you'd like to precede those SAM values.

--keep-com
^^^^^^^^^^

Let's say you already have SAM tags in your FASTQ header comments, and you want to keep them rather than overwrite them (splitcode, by default, will automatically get rid of anything in the FASTQ header comments when you run it). You can preserve those SAM tags that already exist via the ``--keep-com`` option.

.. tip::

  ``--keep-com`` is especially useful when you want to stream output from another program into splitcode. The other program might perform operations that generate SAM tags and you might want splitcode to keep those tags as splitcode does its own operations.

