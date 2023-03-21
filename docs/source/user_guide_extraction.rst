.. _Extraction guide:

User guide: Extraction
======================

Extraction
^^^^^^^^^^

Sequences that you want to extract can be specified in the **config file header** using the ``@extract`` directive followed by an expression of what you want to extract and how. The extraction options are listed below:


Extracting relative to a tag or tag group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To extract relative to a tag or tag group, specify the following four things:

#. The **tag or group name** (tag IDs should be enclosed in single curly braces, i.e. ``{tag_id}`` whereas group names should be enclosed in double curly braces, i.e. ``{{group_name}}``.
#. An optional **spacer** denoting how many bp's away from the tag should the extraction be done.
#. The **name** you want to give the that sequence you want to extract
#. The **length** of the sequence you want to extract

For example, to extract a 6-bp sequence, which you decide to name **xxx**, immediately following identification of the tag with tag ID: **BC**, you'd write in the config file header:

``@extract {BC}<xxx[6]>``

Now let's say you want to extract the 6-bp sequence 2 bp's following identification of **BC**. You'd then write instead:

``@extract {BC}2<xxx[6]>``

You could also extract the 6-bp sequence 2 bp's *before* **BC** via:

``@extract <xxx[6]>2{BC}``

What happens because we named it **xxx**? Our output file name would be named **xxx.fastq** or **xxx.fastq.gz** (in the case that we're working with compressed gzip'd files). If using **--pipe**, the output gets interleaved into the standard output stream and the extracted sequence will appear in the output right before the read sequences.

.. seealso::

   :ref:`example page`
     The example in this documentation provides a sample usage of the ``@extract`` directive.


Extracting relative to a location
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to extracting sequences relative to a tag, you can also extract sequences relative to a location (i.e. a specific file at a specific read position). The location is specified as ``file:position`` where **file** is the zero-indexed file number (i.e. file #0, file #1, etc.) and **position** is the position within the read (again, zero-indexed, such that 0 means you're starting at the beginning of the read).

For example, given two files: R1.fastq and R2.fastq, to extract an 8-bp sequence (named xxx) following the first 10 bp's of R2.fastq, you'd write:

``@extract 1:10<xxx[8]>``

Additionally, you can use **-1** if you want to extract a sequence at the end of the read; for example, you can extract the last 8-bp of reads in R2.fastq by writing:

``@extract <xxx[8]>1:-1``


Extracting between two things
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

splitcode allows you to extract sequences between two tags or between a location and a tag (in effect, *sandwiching* a sequence to be extracted). In this configuration, you don't need to specify a length for the sequence you want to extract. Here are some examples:

* Extracting between two tags: If you want to extract a sequence between a tag with tag id **tag_A** and a tag in the group **group_1**, you can write:
  
  ``@extract {tag_A}<xxx>{{group_1}}``

* Extracting between a tag and a location: If you want to extract a sequence between the tag **tag_A** and position 30 of the reads in the FASTQ file #0, you can write the following:
  
  ``@extract {tag_A}<xxx>0:30``

.. tip::

   The extraction can sometimes fail. For example, if you enter the following:
   
   ``@extract {tag_A}<xxx>{tag_B}``
   
   But you don't encounter an instance of tag_A followed by tag_B), the extracted sequence will be empty. You can also put more constraints on the extraction: say you want to extract between tag_A and the end of the read in FASTQ file #0, but only if the extracted sequence is between 2 and 4 bp's in length, you can specify this as:
   
   ``@extract {tag_A}<xxx[2-4]>0:-1``
   
   If this criteria is not met, the extracted sequence will be empty.

.. tip::

   You can still use spacers when extracting between two tags. For example, if you want the to begin 1 bp after tag_A and 2 bp's before tag_B, you'd write:
   
   ``@extract {tag_A}1<xxx>2{tag_B}``

Extracting tags as-is
~~~~~~~~~~~~~~~~~~~~~

Although we oftentimes want to extract unknown sequences, sometimes we might also want to extract the tags supplied in the config file when they are identified. This is useful for isolating identified tag sequences into their own separate file. There are a few options we have here:

* Extracting tags in its unmodified form:
  
  ``@extract <xxx{tag_A}>`` allows us to extract the sequence associated with the tag named **tag_A** exactly as it is specified in the config file when the tag is identified within a read.

* Extracting tags as found in reads via ``@``:
  
  ``@extract <xxx{@tag_A}>`` allows us to extract the sequence associated with the tag named **tag_A** in its form found in the read when the tag is identified within a read. Unlike the above, if the tag sequence as found in the read has mismatches, the mismatched sequence is extracted (not the original sequence as specified in the config file).

* Extracting tag substitutions via ``#``:

  ``@extract <xxx{#tag_A}>`` allows us to extract the substituted sequence (i.e. the sequence supplied in the **subs** column for **tag_A** in the config file) upon encountering **tag_A** in a read.

* Extracting all tags stitched together via ``{*}``:

  ``@extract <xxx{*}>`` allows us to extract all successfully identified tag sequences stitched together.

.. tip::

   These options can be used in conjunction with other options. See the following:
   
   ``@extract <xxx[15-25]{*}>`` means only do the extraction if the sequence generated by stitching all sequences (in the form found in the config file) together is between 15 and 25 bp's in length.
   
   ``@extract <xxx{#*}>`` means extracting the substituted sequences of the identified tags all stitched together.


Reverse complementing extracted sequence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can extract the reverse complement of a sequence by putting a ``~`` in front of the extracted sequence name. For example, to extract the reverse complement of the 8-bp sequence immediately following the tag **tag_A**, do the following:

``@extract {tag_A}<~xxx[8]>``

.. _Multiple extractions guide:

Multiple extraction sequences
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Multiple instances of a single extraction within a read: They get stitched together.

  ``@extract {tag_A}<xxx[8]>`` if encountered multiple times in a read: splitcode will extract all instances of the 8-bp sequence following **tag_A** whenever **tag_A** is identified within the read. All those 8-bp extracted sequences will be stitched together into a single sequence in the final **xxx.fastq** file (or in the interleaved output when using **--pipe**).

* Multiple extractions specified (comma-separated) using the same name: Each extraction gets stitched together.

  ``@extract {tag_A}<xxx[8]>,{{group_2}}<xxx[3]>``: With each encounter of **tag_A** or **group_2**, splitcode will keep adding on the extracted sequence (the next 8 bp's for **tag_A** or the next 3 bp's for **group_2**) to form a single final sequence that gets placed in the resulting **xxx.fastq** file (or in the interleaved output when using **--pipe**).

* Multiple extractions specified (comma-separated) using *different* names: Each extraction gets put in a different file.

  ``@extract {tag_A}<xxx[8]>,{{group_2}}<rrr[3]>``: For each encounter of **tag_A**, splitcode will extract the 8-bp's following it and put it into **xxx.fastq**. For each encounter of **group_2**, splitcode will extract the 3 bp's following it and put it into **rrr.fastq**. If, instead, **--pipe** is used as output, the interleaved output will consist of two separate read sequences: the ***xxx*** read sequence, then the **rrr** read sequence, right before the rest of the output read sequences.
  
.. tip::

   ``@no-chain`` specified in the config file header can disable the "stitching" behavior such that only the first encounter of a name (e.g. xxx) is extracted.

Output options
~~~~~~~~~~~~~~

In addition to the default output options (named FASTQ files or interleaved output via pipe), there are additional output options you can specify for extracted sequences:

* **--empty** Use this to enter a sequence to put in place of empty sequences in case the final extracted read sequence has nothing in it.

   * **--empty-remove**: Use this to completely remove empty sequences from output (Warning: This will end up breaking the proper pairing of reads with one another).

   * Note: These options apply to all read sequences that might be empty, not just extracted read sequences.

* **--x-only** Use this to output only all of the extracted sequences (and the final barcodes if **--assign** is supplied) but do NOT output the other read sequences.

* **--x-names** Use this to put the extracted sequences into the header of the FASTQ file. By default, the extracted sequences will be prepended with the SAM tag **RX:Z:**, such as *RX:Z:GATGATGG* or *RX:Z:GATGATGG-ATCC* (in the case that two different names are given) in the read name header. This is so that downstream tools can make use of the SAM tags.

* **--no-x-out** Use this to not output extracted sequences; this should be used with **--x-names** because if that option is supplied, the extracted sequences will still appear in the read name header. In other words, use these two options together if you prefer your extracted sequences to be in the read header (e.g. as SAM tags) rather than outputted in FASTQ format.
