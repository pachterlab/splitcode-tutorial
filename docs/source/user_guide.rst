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


