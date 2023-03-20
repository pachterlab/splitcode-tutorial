User guide
==========

.. _Extraction guide:

Extraction
^^^^^^^^^^

Sequences that you want to extract can be specified in the **config file header** using the `@extract` directive followed by an expression of what you want to extract and how. The extraction options are listed below:

Extracting relative to a tag or tag group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To extract relative to a tag or tag group, specify the following four things:

#. The **tag or group name** (tag IDs should be enclosed in single curly braces, i.e. ``{tag_id}`` whereas group names should be enclosed in double curly braces, i.e. ``{{group_name}}``.
#. An optional **spacer** denoting how many bp's away from the tag should the extraction be done.
#. The **name** you want to give the that sequence you want to extract
#. The **length** of the sequence you want to extract

For example, to extract a 6-bp sequence, which you decide to name **xxx**, immediately following identification of the tag with tag ID: **BC**, you'd write in the config file header: ``@extract {BC}<xxx[6]>``. Now let's say you want to extract the 6-bp sequence 2 bp's following identification of **BC**. You'd then write instead: ``@extract {BC}2<xxx[6]>``. You could also extract the 6-bp sequence 2 bp's *before* **BC** via ``@extract <xxx[6]>2{BC}``. What happens because we named it **xxx**? Our output file name would be named **xxx.fastq** or **xxx.fastq.gz** (in the case that we're working with compressed gzip'd files).

.. seealso::

   :ref:`example page`
     The example in this documentation provides a sample usage of the ``@extract`` directive.

Extracting relative to a location
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to extracting sequences relative to a tag, you can also extract sequences relative to a location (i.e. a specific file at a specific read position). The location is specified as ``file:position`` where **file** is the zero-indexed file number (i.e. file #0, file #1, etc.) and **position** is the position within the read (again, zero-indexed, such that 0 means you're starting at the beginning of the read).

For example, given two files: R1.fastq and R2.fastq, to extract an 8-bp sequence (named xxx) following the first 10 bp's of R2.fastq, you'd write ``@extract 1:10<xxx[8]>``. Additionally, you can use **-1** if you want to extract a sequence at the end of the read; for example, you can extract the last 8-bp of reads in R2.fastq by writing ``@extract <xxx[8]>1:-1``.



Extracting between two things
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

splitcode allows you to extract sequences between two tags or between a location and a tag (in effect, *sandwiching* a sequence to be extracted). In this configuration, you don't need to specify a length for the sequence you want to extract. Here are some examples:

* Extracting between two tags: If you want to extract a sequence between a tag with tag id **tag_A** and a tag in the group **group_1**, you can write ``@extract {tag_A}<xxx>{{group_1}}``.
* Extracting between a tag and a location: If you want to extract a sequence between the tag **tag_A** and position 30 of the reads in the FASTQ file #0, you can write ``@extract {tag_A}<xxx>{{group_1}}``.

.. tip::

   If the extraction fails (e.g. you specify ``@extract {tag_A}<xxx>{tag_B}`` but you don't encounter an instance of tag_A followed by tag_B), the extracted sequence will be empty. You can also put more constraints on the extraction: say you want to extract between tag_A and the end of the read in FASTQ file #0, but only if the extracted sequence is between 2 and 4 bp's in length, you can specify this as ``@extract {tag_A}<xxx[2-4]>0:-1``. If this criteria is not met, the extracted sequence will be empty.

Reverse complementing extracted sequence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can extract the reverse complement of a sequence by putting a ``~`` in front of the extracted sequence name. For example ``@extract {tag_A}<~xxx[8]>`` will extract the reverse complement of the 8-bp sequence immediately following the tag **tag_A**.
