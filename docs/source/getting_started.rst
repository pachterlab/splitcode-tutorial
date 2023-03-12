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
  cmake ..
  make
  make install


Graphical User Interface (GUI)
^^^^^^^^^^^^
To use splitcode's GUI, please visit `https://pachterlab.github.io/splitcode/ <https://pachterlab.github.io/splitcode/>`_ (Note: GUI is still under development)

.. note::

   This GUI is under development and is a work in progress.



Command-line structure
^^^^^^^^^^^^^^^^^^^^^^
To retrieve a list of random ingredients,
you can use the ``lumache.get_random_ingredients()`` function:

.. autofunction:: lumache.get_random_ingredients

The ``kind`` parameter should be either ``"meat"``, ``"fish"``,
or ``"veggies"``. Otherwise, :py:func:`lumache.get_random_ingredients`
will raise an exception.

.. autoexception:: lumache.InvalidKindError

For example:

>>> import lumache
>>> lumache.get_random_ingredients()
['shells', 'gorgonzola', 'parsley']



Basic usage
^^^^^^^^^^^
Hello world
