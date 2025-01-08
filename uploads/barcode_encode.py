#!/usr/bin/env python3

import sys

NUCLEOTIDE_MAP = {
    'A': 0,  # 00
    'C': 1,  # 01
    'G': 2,  # 10
    'T': 3,  # 11
}

def read_radix_file(filename):
    """
    Reads the radix file (no header), each line with:
      groupId, itemName, domain, radix

    We build a list 'table' in the order groups appear.

    For each new groupId encountered, we create a new entry:
        {
          "groupId": <str>,
          "domain": <int>,
          "radix":  <int>,
          "names":  []
        }

    Then we append the 'itemName' to 'names'.
    """
    table = []
    current_group_id = None
    current_entry = None

    with open(filename, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue  # skip blank lines

            parts = line.split()
            if len(parts) < 4:
                sys.exit(f"Error in {filename}: line has fewer than 4 columns: '{line}'")

            group_id, item_name, domain_str, radix_str = parts[0], parts[1], parts[2], parts[3]
            domain = int(domain_str)
            radix  = int(radix_str)

            # If it's a new groupId, create a new entry in 'table'
            if group_id != current_group_id:
                current_group_id = group_id
                current_entry = {
                    "groupId": group_id,
                    "domain": domain,
                    "radix":  radix,
                    "names":  []
                }
                table.append(current_entry)
            else:
                # same group as previous line: confirm domain & radix match
                if domain != current_entry["domain"] or radix != current_entry["radix"]:
                    sys.exit(f"Error: Inconsistent domain/radix for group '{group_id}' "
                             f"in file '{filename}'.")

            # Append the item name to the group's name list
            current_entry["names"].append(item_name)

    return table

def nucleotide_string_to_int(nt_string):
    """
    Convert a string of nucleotides (A, C, G, T) into an integer by mapping:
      A -> 0 (00 in binary)
      C -> 1 (01)
      G -> 2 (10)
      T -> 3 (11)

    Each nucleotide is 2 bits, so a string of length L => 2*L bits.

    Example:
      "AAC" -> (A=00, A=00, C=01) -> binary "000001" -> decimal 1
    """
    encoded_val = 0
    for nt in nt_string:
        encoded_val <<= 2
        if nt not in NUCLEOTIDE_MAP:
            raise ValueError(f"Invalid nucleotide '{nt}' in string '{nt_string}'.")
        encoded_val |= NUCLEOTIDE_MAP[nt]
    return encoded_val

def decode_mixed_radix(encoded_int, table):
    """
    Decodes an integer (potentially up to 64 bits or more) into a list of indices,
    one for each group in 'table'.

    We assume table[i]["radix"] is the product of the domains of
    all *previous* groups in the same order. We decode from last to first:

      for i in reversed(range(k)):
        units = temp // table[i]["radix"]
        value_i = units % table[i]["domain"]
        temp -= (value_i * table[i]["radix"])

    Returns a list of integer values (same length as 'table').
    """
    k = len(table)
    values = [0] * k
    temp = encoded_int

    for i in reversed(range(k)):
        dom = table[i]["domain"]
        rad = table[i]["radix"]

        units = temp // rad
        value_i = units % dom
        values[i] = value_i

        temp -= (value_i * rad)

    return values

def main():
    if len(sys.argv) != 4:
        sys.exit(f"Usage: {sys.argv[0]} <radix_file> <input_file> <output_file>")

    radix_file = sys.argv[1]
    input_file = sys.argv[2]
    output_file = sys.argv[3]

    # 1) Read the radix file
    table = read_radix_file(radix_file)

    # 2) Process the input file line-by-line, convert nucleotides -> int, decode, write to output
    with open(input_file, "r", encoding="utf-8") as fin, \
         open(output_file, "w", encoding="utf-8") as fout:

        for line in fin:
            nt_str = line.strip()
            if not nt_str:
                continue  # skip empty lines

            # Convert nucleotides to integer
            try:
                encoded_val = nucleotide_string_to_int(nt_str)
            except ValueError as e:
                # If there's an invalid nucleotide, handle or skip
                fout.write(f"{nt_str}\t<ERROR: {e}>\n")
                continue

            # Decode the integer via mixed-radix
            values = decode_mixed_radix(encoded_val, table)

            # For each group i, if value == domain-1 => special => skip
            decoded_items = []
            for i, val in enumerate(values):
                dom   = table[i]["domain"]
                names = table[i]["names"]
                # "val" is in [0..dom-1]
                if val != (dom - 1):
                    if val < len(names):
                        decoded_items.append(names[val])
                    else:
                        decoded_items.append("<MISSING_NAME?>")

            # Join with commas
            decoded_str = ",".join(decoded_items)

            # Output: "original_nucleotide_string <TAB> decoded_str"
            fout.write(f"{nt_str}\t{decoded_str}\n")

if __name__ == "__main__":
    main()
