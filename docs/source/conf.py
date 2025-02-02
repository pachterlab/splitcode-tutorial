# Configuration file for the Sphinx documentation builder.

# -- Project information

project = 'splitcode'
copyright = '2025, Delaney K. Sullivan, Lior Pachter'
author = 'Delaney K. Sullivan, Lior Pachter'

release = '0.31.0'
master_doc = 'index'

# -- General configuration

extensions = [
    'sphinx.ext.duration',
    'sphinx.ext.doctest',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.intersphinx',
    'sphinx.ext.autosectionlabel',
]

autosectionlabel_prefix_document = True
autosectionlabel_maxdepth = 2

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'
