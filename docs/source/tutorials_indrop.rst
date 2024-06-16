.. _inDrops guide:

inDrops guide
=============

Introduction
^^^^^^^^^^^^

**inDrops** is a droplet microfluidics-based single-cell RNA-seq method. This tutorial will describe processing the original **version 1** of the technology, which involves two rounds of barcoding (each using 384 barcodes). For our example, we will use the dataset at `GSM1599501 <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM1599501>`_ (SRR accession: `SRR1784317 <https://www.ncbi.nlm.nih.gov/sra/?term= SRR1784317>`_).

Read structure
^^^^^^^^^^^^^^

The **R1** reads contain the first (8-11 bp) barcode, followed by a constant 22-bp GAGTGATTGCTTGTGACGCCTT sequence, followed by the second (8-bp) barcode, followed by a 6-bp UMI.

The **R2** reads contain the sequence to be aligned to the genome/transcriptome.

Barcode list preprocessing
^^^^^^^^^^^^^^^^^^^^^^^^^^

Here are the two lists of barcodes (one for each round of barcoding):

1. `inDrop_barcode1_list.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/indrop/inDrop_barcode1_list.txt>`_
2. `inDrop_barcode2_list.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/indrop/inDrop_barcode2_list.txt>`_

The ``inDrop_barcode1_list.txt`` file is the file that contains variable length barcodes.

First, note that some preprocessing will need to happen with the first 384 barcodes list, because the barcodes are of variable length (and also, in the list above, the barcodes are reverse complemented). Thus, for each barcode in the list, we will 1) reverse complement it, then 2) pad it if necessary so that it reaches 11-bp in length. Since we know that the constant region starts with GAG, if a barcode is only 8-bp long, we pad GAG, if it is only 9-bp long, we pad GA, and if it only 10-bp long, we pad G.

.. code-block:: shell
   
   cat inDrop_barcode1_list.txt|tr ACGTacgt TGCAtgca | rev | awk 'length($0)==8{$0=$0 "GAG"} length($0)==9{$0=$0 "GA"} length($0)==10{$0=$0 "G"} {print}' > list1.txt


We will use the newly created `list1.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/indrop/list1.txt>`_ for further processing.

Config file
^^^^^^^^^^^

Next, we'll use a `config.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/indrop/config.txt>`_ file as follows, which first matches a barcode in the modified first barcodes list (allowing one substitution error) in the first 11-bp's, then matches the remaining 19-bp of the 22-bp constant region (remember, the first 3 nucleotides, GAG, are the end-padding of the shorter barcodes, so, since those could appear as part of the barcode region, we omit them when searching for the constant region). The 19-bp's are matched with two-substitution error tolerance, then the second barcodes list is matched with a one-substitution error tolerance.

The ``@extract`` pattern will extract the first barcode (11-bp), followed by the second barcode (8-bp), followed by the 6-bp UMI sequence into a new ``modified_R1.fastq.gz`` file. Barcode error correction is already technically performed since the barcodes are extracted in the original form that they exist in the config file.

.. code-block:: text
  :caption: config.txt
  
  @extract <modified_R1{{barcode1}}>,<modified_R1{{barcode2}}>,{{barcode2}}<modified_R1[6]>
  tag                        location   distance  group     maxFindsG  minFindsG   next
  TGATTGCTTGTGACGCCTT        0:11:33    2         adapter   1          1           {{barcode2}}0-0
  list1.txt$                 0:0:11     1         barcode1  1          1           -
  inDrop_barcode2_list.txt$  0:30       1         barcode2  1          1           -


Running splitcode
^^^^^^^^^^^^^^^^^

Now with our `config.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/indrop/config.txt>`_ file and our `list1.txt <https://raw.githubusercontent.com/pachterlab/splitcode-tutorial/main/uploads/indrop/list1.txt>`_ (i.e. our modified first barcodes list) in place, we can run splitcode as follows to create a new set of reads:

.. code-block:: shell
   
   splitcode --nFastqs=2 --config=config.txt --gzip --select=1 --output=modified_R2.fastq.gz SRR1784317_R1.fastq.gz SRR1784317_R2.fastq.gz

The output files will be ``modified_R1.fastq.gz`` and ``modified_R2.fastq.gz`` where R1 contains the merged 19-bp barcode (11-bp + 8-bp) followed by the 6-bp UMI.

.. hint::

   Want to save space and time? You can use ``--pipe`` instead of ``--output`` to produce interleaved paired-end reads that could be streamed directly into tools that accept interleaved reads.

.. hint::

   Want to view (perhaps for debugging purposes) exactly what barcodes are matched in what reads? You can use ``--mod-names`` to modify the read header of the output files to identify the barcode sequences that are present in a given read.


Downstream processing
^^^^^^^^^^^^^^^^^^^^^

Now, the sequences have a structure that can be readily interpreted by a single-cell RNA-seq mapping program (e.g. STARsolo, alevin-fry, or kallisto | bustools). Here, we will use kallisto | bustools (via `kb-python <https://github.com/pachterlab/kb_python>`_) as an example of how to map these newly modified reads. kallisto | bustools can interpret a user-specified read structure via the ``-x`` option (see `page 7 of this manual <https://www.biorxiv.org/content/10.1101/2023.11.21.568164v2.full.pdf>`_). Assuming we have created a transcriptome index ``index.idx`` and its corresponding ``t2g.txt`` file from running ``kb ref``, we can then run the read mapping step as follows to produce output count matrices:

.. code-block:: shell
   
   kb count -x 0,0,19:0,19,25:1,0,0 -w None -i index.idx -g t2g.txt modified_R1.fastq.gz modified_R2.fastq.gz


References
^^^^^^^^^^

The following references, which either describe the method, were posted prior to, or contributed to the development of this tutorial, are acknowledged and credited:

1. Klein AM, Mazutis L, Akartuna I, Tallapragada N, Veres A, Li V, Peshkin L, Weitz DA, Kirschner MW. Droplet barcoding for single-cell transcriptomics applied to embryonic stem cells. Cell. 2015 May 21;161(5):1187-201. `https://doi.org/10.1016/j.cell.2015.04.044 <https://doi.org/10.1016/j.cell.2015.04.044>`_

2. Zilionis R, Nainys J, Veres A, Savova V, Zemmour D, Klein AM, Mazutis L. Single-cell barcoding and sequencing using droplet microfluidics. Nature protocols. 2017 Jan;12(1):44-73. `https://doi.org/10.1038/nprot.2016.154 <https://doi.org/10.1038/nprot.2016.154>`_

3. `Teichmann Lab inDrops read structure description <https://teichlab.github.io/scg_lib_structs/methods_html/inDrop.html>`_


