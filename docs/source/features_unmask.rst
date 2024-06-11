Unmasking
=========

An auxiliary feature of ``splitcode`` is the ability to unmask sequences, given a masked FASTA file and the corresponding original FASTA file. For example, if there is a version of a genome masked such that certain nucleotides are replaced with N's and one wishes to extract those original nucleotides that were masked (assuming the original unmasked genome is available), one can do so via the following:

.. code-block:: shell

  splitcode --unmask genome.fasta masked_genome.fasta [fasta_header]

The output will be written to standard output.

As an example, let's say genome.fasta (the original genome) and masked_genome.fasta (the masked genome) look as follows:

.. code-block:: text
  :caption: genome.fasta

  >read1
  ATGAGT
  >read2
  ACACTT


.. code-block:: text
  :caption: masked_genome.fasta

  >read1
  ANNNNT
  >read2
  NCACTN

The output of the command will look like:

.. code-block:: text

  >1
  TCAG
  >2
  A
  >3
  T

.. tip::

   The optional ``[fasta_header]`` can be provided to specify what the sequence names of the output should be. Otherwise, by default, the sequence names will look like >1, >2, >3, ...


