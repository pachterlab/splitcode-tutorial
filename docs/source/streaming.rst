.. _interleave page:

Streaming and Interleaving
==========================

One of splitcode's key features is the ability to directly stream its output into other programs without the overhead of creating intermediate files. This is possible because splitcode can write interleaved output to standard output.

Output
^^^^^^

While splitcode can write output in the format of (possibly gzipped) FASTQ files, splitcode can also write its output to standard output. This is possible by using the ``--pipe`` option when running splitcode. When this option is set, the output is written to standard output automatically in interleaved FASTQ format.

The repeating output is as follows:

1. The **final barcode** when ``--assign`` is set
2. One or more of the **extracted UMI-like sequences** set by ``-x`` (e.g. if we have three different extraction names, we'll write 3 reads in the order the names were specified in the extraction string)
3. The output sequences (the number of reads being what is set by ``--nFastqs``)

.. seealso::

   :ref:`Example Pipe Output`
     The example in this documentation shows how ``--pipe`` works when writing interleaved output to standard output.


Input
^^^^^

splitcode can also read interleaved *input* produced by other programs. For this, the ``--inleaved`` option is used. Imagine that we have a program ``other_program`` that reads in two FASTQ files: **R1.fq** and **R2.fq** and generates output in interleaved format. There are two ways of reading interleaved input (see below):

Reading by pipelines
~~~~~~~~~~~~~~~~~~~~

There are four things we need to specify for this:

* Use ``|`` for piping from **other_program**
* Use ``-`` at the end to specify that we are receiving input from **other_program**
* Use ``--inleaved`` option to specify that we are receiving interleaved input from **other_program**
* Use ``--nFastqs`` option to specify the number of reads per interleaved input (in this case, **2**)

See below:

.. code-block:: text

  other_program R1.fq R2.fq | splitcode [options] --nFastqs=2 --inleaved -
  


Reading by process substitution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For reading input by process substitution, we need to specify the following:

* Use ``<(other_program R1.fq R2.fq)`` for the process substitution
* Use ``--inleaved`` option to specify that we are receiving interleaved input from **other_program**
* Use ``--nFastqs`` option to specify the number of reads per interleaved input (in this case, **2**)

See below:

.. code-block:: text

  splitcode [options] --nFastqs=2 --inleaved <(other_program R1.fq R2.fq)


Interfacing with other programs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here, we show how to read input from other programs into splitcode and direct splitcode's output to other programs. Like previously, imagine that we have paired-end FASTQ files: **R1.fq** and **R2.fq**.

cutadapt to splitcode to bwa
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cutadapt version 4.3 and bwa version 0.7.17 (with a reference FASTA file named **ref.fa** indexed via ``bwa index ref.fa``)

.. code-block:: text

  cutadapt --interleaved -q 20 -a ACGT -A TGCA R1.fq R2.fq | splitcode -c config.txt --nFastqs=2 --pipe --inleaved - | bwa mem -p ref.fa -

Here, cutadapt reads in the two FASTQ files and interleaves the output (via ``--interleaved``), which splitcode takes in as paired-end input (via ``-`` and via ``--inleaved``) and then interleaves its output (via ``--pipe``), which is then fed into bwa (where the ``-p`` option allows interleaved paired reads to be inputted).

If a program doesn't support reading in piped input, you can used named pipes via the unix command ``mkfifo``.

.. tip::

  splitcode can transfer the SAM tags put in the FASTQ header comments output to bwa by giving the ``-C`` option to bwa. This is useful for splitcode options like --x-names or --com-names which put information into SAM tags in the output FASTQ headers.

splitcode to kallisto
~~~~~~~~~~~~~~~~~~~~~

**kallisto** versions above 0.48.0 and **kb-python** versions ≥0.28.0 allow passing in interleaved input.

Here, let's say we have a kallisto index named **index.idx** and **R1.fq** contains the biological read while **R2.fq** contains only technical sequences (where the first 8-bp is the UMI).

We can direct splitcode into kallisto using kallisto's ``--inleaved`` option and kallisto's ``-`` option (to read from the pipe) as follows (as an example):

.. code-block:: text

  splitcode -c config.txt --assign --mapping=mapping.txt --nFastqs=2 --pipe R1.fq R2.fq | kallisto bus -x 0,0,16:2,0,8:1,0,0 --inleaved -i index.idx -o output_dir/ -

Here, remember that with ``--assign``, splitcode will have three reads per interleaved output; the first read is the final barcode sequence, the second read is the (possibly modified) R1.fq, and the third read is the (possibly modified) R2.fq.  **kallisto** therefore needs to handle three outputs.

The structure of the ``-x`` option tells kallisto how to parse the input files (or, in this case the input stream) it is given. The structure is as follows:

``-x barcode:umi:sequence``

Each component (**barcode**, **UMI**, and the **sequence** to be mapped) can further be decomposed into parts:

``file_number,start_position,end_position``

Therefore, the above command is resolved as follows:

* **barcode** is located at **0,0,16**: ``file #0, start position 0, end position 16`` (remember, this is the "final barcode sequence" which is encoded by splitcode into a 16 bp sequence)
* **UMI** is located at **2,0,8**: ``file #2, position 0, end position 8``; (aka first 8 bp of the possibly modified R2.fq file)
* **sequence** to be mapped is **1,0,0**: ``file #1, position 0, end position 0``; (note that if end position is 0, that means go until the end of the line -- here, since start position is also 0, this basically means take the entire line of the possibly modified R1.fq file)



splitcode to splitcode
~~~~~~~~~~~~~~~~~~~~~~

splitcode can even interface with itself! If one run of splitcode doesn't give you the processing+parsing that you need, you can add another layer to it using the output of the first round of splitcoding.

.. code-block:: text

  splitcode [options] --pipe R1.fq R2.fq | splitcode [options] --inleaved -


