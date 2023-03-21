Reference guide
===============


Config file options
^^^^^^^^^^^^^^^^^^^

Sequence Identification Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These options are supplied as a tab-delimited table in the config file, with each option being a column.

.. list-table:: 
   :widths: 15 35 35 15 
   :header-rows: 1

   * - Option
     - Description
     - Additional info
     - Example
   * - tags
     - Tag sequence
     - String of ATCG bases. Alternately, can supply a file containing multiple tag sequences.
     - GGATC
   * - ids
     - Tag name/ID
     - 
     - tag_A
   * - groups
     - Tag group name/ID
     - Tags can be grouped together under a group name.
     - grp_A
   * - distances
     - Allowable error tolerance
     - Supports setting hamming distance, indel, and total error (hamming+indel) allowance.
     - 2
   * - locations
     - Where a tag should be searched for in a read
     - Can specify file, start position, and end position.
     - 0:5:13
   * - minFinds
     - Minimum number of times a tag must be found in a read
     - If this isn’t met, the read is discarded
     - 3
   * - minFindsG
     - Minimum number of times a tag *group* must be found in a read
     - If this isn’t met, the read is discarded
     - 3
   * - maxFinds
     - Maximum number of times a tag must be found in a read
     - Once this is reached, the program simply stops looking for that tag
     - 5
   * - maxFindsG
     - Maximum number of times a tag *group* must be found in a read
     - Once this is reached, the program simply stops looking for any tag belonging to that group
     - 5
   * - left
     - Whether tag should be a left trimming point (0 = no; 1 = yes)
     - At the location the tag is found, that tag and all bases to the left of the tag in the read are removed
     - 1
   * - right
     - Whether tag should be a right trimming point (0 = no; 1 = yes)
     - At the location the tag is found, that tag and all bases to the right of the tag in the read are removed
     - 0
   * - next
     - What tag ID or group ID must come after the tag
     - When the tag is found, only the tag ID or group ID specified as "next" will be searched for
     - {tag_A}
   * - previous
     - What tag ID or group ID must come before the tag
     - The tag will not be searched for unless the tag ID or group ID specified as "previous" was found right before
     - {{grp_A}}
   * - subs
     - Sequence to substitute tag with when tag is found in read
     - Note: Useful for error correction: one can specify substituting the original tag sequence in if a mismatched version was found
     - NNNN
   * - partial5
     - Adapter trimming for adapters at the 5′ end
     - Experimental; Still under development
     - 
   * - partial3
     - Adapter trimming for adapters at the 3′ end
     - Experimental; Still under development
     - 

Command-line options
^^^^^^^^^^^^^^^^^^^^

splitcode help menu which can be accessed via ``splitcode -h``

.. note::

  Since this manual uses the splitcode config file for setting config options, the command-line arguments that set the config options are not necessary and therefore are not shown.  

.. code-block :: text
  :caption: splitcode help menu
  
  Usage: splitcode [arguments] fastq-files
  
  Options (configurations supplied in a file):
  -c, --config     Configuration file
  Output Options:
  -m, --mapping    Output file where the mapping between final barcode sequences and names will be written
  -o, --output     FASTQ file(s) where output will be written (comma-separated)
                   Number of output FASTQ files should equal --nFastqs (unless --select is provided)
  -O, --outb       FASTQ file where final barcodes will be written
                   If not supplied, final barcodes are prepended to reads of first FASTQ file (or as the first read for --pipe)
  -u, --unassigned FASTQ file(s) where output of unassigned reads will be written (comma-separated)
                   Number of FASTQ files should equal --nFastqs (unless --select is provided)
  -E, --empty      Sequence to fill in empty reads in output FASTQ files (default: no sequence is used to fill in those reads)
      --empty-remove Empty reads are stripped in output FASTQ files (don't even output an empty sequence)
  -p, --pipe       Write to standard output (instead of output FASTQ files)
  -S, --select     Select which FASTQ files to output (comma-separated) (e.g. 0,1,3 = Output files #0, #1, #3)
      --gzip       Output compressed gzip'ed FASTQ files
      --out-fasta  Output in FASTA format rather than FASTQ format
      --keep-com   Preserve the comments of the read names of the input FASTQ file(s)
      --no-output  Don't output any sequences (output statistics only)
      --no-outb    Don't output final barcode sequences
      --no-x-out   Don't output extracted UMI-like sequences (should be used with --x-names)
      --mod-names  Modify names of outputted sequences to include identified tag names
      --com-names  Modify names of outputted sequences to include final barcode sequence ID
      --seq-names  Modify names of outputted sequences to include the sequences of identified tags
      --x-names    Modify names of outputted sequences to include extracted UMI-like sequences
      --x-only     Only output extracted UMI-like sequences
  -X, --sub-assign Assign reads to a secondary sequence ID based on a subset of tags present (must be used with --assign)
                   (e.g. 0,2 = Generate unique ID based the tags present by subsetting those tags to tag #0 and tag #2 only)
                   The names of the outputted sequences will be modified to include this secondary sequence ID
  -C  --compress   Set the gzip compression level (default: 1) (range: 1-9)
  -M  --sam-tags   Modify the default SAM tags (default: CB:Z:,RX:Z:,BI:i:,SI:i:,BC:Z:)
  Other Options:
  -N, --nFastqs    Number of FASTQ file(s) per run
                   (default: 1) (specify 2 for paired-end)
  -n, --numReads   Maximum number of reads to process from supplied input
  -A, --append     An existing mapping file that will be added on to
  -k, --keep       File containing a list of arrangements of tag names to keep
  -r, --remove     File containing a list of arrangements of tag names to remove/discard
  -y, --keep-grp   File containing a list of arrangements of tag groups to keep
  -Y, --remove-grp File containing a list of arrangements of tag groups to remove/discard
  -t, --threads    Number of threads to use
  -s, --summary    File where summary statistics will be written to
  -h, --help       Displays usage information
      --assign     Assign reads to a final barcode sequence identifier based on tags present
      --inleaved   Specifies that input is an interleaved FASTQ file
      --remultiplex  Turn on remultiplexing mode
      --version    Prints version number
      --cite       Prints citation information
