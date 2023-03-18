Getting started
===============

Installation
^^^^^^^^^^^^
To use splitcode, first install it from source:

.. code-block:: shell

  git clone https://github.com/pachterlab/splitcode
  cd splitcode
  mkdir build
  cd build
  cmake .. -DZLIBNG=ON
  make
  make install


Graphical User Interface (GUI)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To use splitcode's GUI, please visit `https://pachterlab.github.io/splitcode/ <https://pachterlab.github.io/splitcode/>`_

.. note::

   This GUI is under development and is a work in progress.


Overview
^^^^^^^^

splitcode is organized such that....


Command-line structure
^^^^^^^^^^^^^^^^^^^^^^
The command-line structure for running splitcode is as follows:

.. code-block:: shell

  splitcode [arguments] fastq-files

A list of options can be viewed by running ``splitcode -h``

Most often, you'd want to supply a config file to splitcode, specifying how you want your reads to be processed. You'd also want to supply an output option. Here, we demonstrate a basic usage of splitcode where we search for the sequence ATCG and replace it with TTTT.

First, create a config file named ``config.txt`` with the following contents:

::

 ids tags subs
 id1 ATCG TTTT

Next, let's create a sample FASTQ file called ``intro.fastq`` with the following contents:

::

 @read1
 GGGATCGCCC
 +
 ##########
 @read2
 ATCGTTTTTT
 +
 ##########


Then, run the following: 

.. code-block:: shell

  splitcode -c config.txt --nFastqs=1 --pipe intro.fastq

For example:

>>> import lumache
>>> lumache.get_random_ingredients()
['shells', 'gorgonzola', 'parsley']



Basic usage
^^^^^^^^^^^
Hello world
