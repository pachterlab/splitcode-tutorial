.. _Random guide:


Random sequence insertion
=========================

For inserting a random sequence of nucleotides (e.g. to simulate UMIs), one can specify ``@random`` in the config file or use ``--random`` as a command line option to splitcode. The "random" option takes in an expression that looks like: output file number, output position number, random sequence length. So let's say we have the following in the config file:

.. code-block:: text

  @random 0,2,25



 The ``0,2,25`` means insert a **25** nucleotide-long random sequence into output file #0, at position 2 (i.e. after the second nucleotide in the read).

And that's it!



