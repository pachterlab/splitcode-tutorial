Example
=======

Read structure
^^^^^^^^^^^^^^

The structure of the reads from this hypothetical sequencing technology (see image below) contains multiple regions that need to be parsed, including some of variable length.

.. image:: https://raw.githubusercontent.com/pachterlab/splitcode/main/figures/splitcode_example.png
  :width: 725
  :alt: Example image

Config File
^^^^^^^^^^^

The tab-delimited **table** in the **config file** indicates the following config options:

* **groups**: Each tag belongs to a specific group. Here, the group named ``grpA`` contains the tags named *Barcode_A1, Barcode_A2, Barcode_A3* while group ``grpB`` contains the tags named *Barcode_B1, Barcode_B2*.
* **ids**: The names of each tag. Here, there are 5 tags, one for each sequence and they are each given a unique name: ``Barcode_A1``, ``Barcode_A2``, ``Barcode_A3``, ``Barcode_B1``, ``Barcode_B2``
* **tags**: The sequences of the tags themselves. The tag named *Barcode_A1* has sequence ``AAGGA``, the tag named *Barcode_A2* has sequence ``GTGTG``, *Barcode_A3* has sequence ``CGTAT``, *Barcode_B1* has sequence ``GCGCAA``, and *Barcode_B2* has sequence ``CCCGT``. 
* **distances**: The tags in the *grp_A* group have the value ``1`` in the *distances* column, meaning a *hamming distance 1 error tolerance*.
* **next**: The values in the *next* column indicate that after a *grp_A* tag (i.e. Barcode_A1, Barcode_A2, or Barcode_A3) is found, we should next search only for tags in the ``grp_B`` group.

  * Note: The value grp_B is surrounded by two curly braces: ``{{grp_B}}``. The two curly braces indicates group. If we were searching for a tag instead of a group (like if we only wanted to search for only Barcode_B2 next), we'd use only one curly brace, i.e. {Barcode_B2}.

* **maxFindsG**: The *maxFindsG* values of ``1`` mean that the *maximum number of times a specific group can be found is 1* (e.g. after finding a tag in grp_A, stop searching for tags in grp_A).
* **locations**: The *locations* for *grp_A* tags have the value ``0:0:5``, meaning that the tag is found in file #0 (i.e. the R1 file) within positions 0-5 of the read (the first 5 bp's); for *grp_B* tags, splitcode searches file #0 within positions 5-100 (the next 95 bp's).

The **header** in the **config file** indicates the following:

* **@extract**: The expression ``{{grp_B}}3<umi[8]>`` means that once a tag in group ``grp_B`` is found in a read, splitcode will extract a sequence of length ``8``, which we name ``umi``, exactly ``3`` bases after the grp_B tag is found. Thus, the grp_B tag serves as an anchor point for extracting the 8-bp sequence.

  * Note: Just like in the "next" column, grp_B is surrounded by two curly braces: ``{{grp_B}}``, which indicates group. If we wanted to extract relative to a tag ID rather than a group, we'd use only one curly brace to enclose the tag ID.

* **@trim-3**: This option specifies trimming from the 3′-end of reads. We have two values here: The first for file #0 (i.e. the R1 file) and the second for file #1 (i.e. R2 file). Thus, ``0,4`` means we trim ``0`` bp's (i.e. no trimming) for file #0 while we trim ``4`` bp's off of the 3′ end of each read in file #1.

Command-Line Run
^^^^^^^^^^^^^^^^



Output
^^^^^^



