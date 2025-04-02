import re
import requests
from math import prod

# Accelerated ascending algorithm to generate all partitions of a positive integer d
# Information can be found, e.g., at "https://jeromekelleher.net/generating-integer-partitions.html"
# Modified to exclude any partitions containing 1 or d
# d will be the degree of a reducible polynomial with no linear factors, and these partitions correspond to possible degrees of its irreducible factors 
# For example, if d = 6, this will return (2, 2, 2), (2, 4), and (3, 3)

def accel_asc(d):
    if d <= 1:
        return  # No valid partitions if d <= 1
    
    a = [0 for i in range(d + 1)]
    k = 1
    y = d - 1
    while k != 0:
        x = a[k - 1] + 1
        k -= 1
        while 2 * x <= y:
            a[k] = x
            y -= x
            k += 1
        l = k + 1
        while x <= y:
            a[k] = x
            a[l] = y
            partition = a[:k + 2]
            if 1 not in partition and d not in partition:
                yield partition
            x += 1
            y -= 1
        a[k] = x + y
        y = x + y - 1
        partition = a[:k + 1]
        if 1 not in partition and d not in partition:
            yield partition

# If d = d_1 + ... + d_k is a partition from above, set D = d_1 * ... * d_k. This returns all divisors of D which are also divisible by the lcm of the d_i
# These are the degrees of the symmetric groups where we search for transitive subgroups
# For example, for the partition 6 = 2 + 4, we have D = 8 and the divisors 4 and 8

def get_transitive_subgroup_degrees(D, partition):
    divisors = []
    for i in range(1, D + 1):
        if D % i == 0 and all(i % d == 0 for d in partition):
            divisors.append(i)
    return divisors

# Lookup table for GAP / LMFDB labels associated to each partition
# Each entry of the form "x.y" can be used in the URL "https://beta.lmfdb.org/Groups/Abstract/x.y" to find the group's profile
# As above, writing 6 = 2 + 4 will point to the group with ID 48.48, and the relevant URL is "https://beta.lmfdb.org/Groups/Abstract/48.48"
# I downloaded each HTML file and gave them systematic file names to use with this script
# It might be easier to scrape directly from LMFDB, or to access their API, although the latter is incomplete as of writing this
# In any case, I couldn't find a more elegant solution than hard-coding the group IDs corresponding to each direct product

lookup_table = {
    5: {(2, 3): "12.4"},
    6: {(2, 2, 2): "8.5", (2, 4): "48.48", (3, 3): "36.10"},
    7: {(2, 2, 3): "24.14", (2, 5): "240.189", (3, 4): "144.183"},
    8: {(2, 2, 2, 2): "16.14", (2, 2, 4): "96.226", (2, 3, 3): "72.46", (2, 6): "1440.5842", (3, 5): "720.767", (4, 4): "576.8653"},
    9: {(2, 2, 2, 3): "48.51", (2, 2, 5): "480.1186", (2, 3, 4): "288.1028", (2, 7): "10080.l", (3, 3, 3): "216.162", (3, 6): "4320.bg", (4, 5): "2880.dv"},
    10: {(2, 2, 2, 2, 2): "32.51", (2, 2, 2, 4): "192.1537", (2, 2, 3, 3): "144.192", (2, 2, 6): "2880.du", (2, 3, 5): "1440.5849", (2, 4, 4): "1152.157851", (2, 8): "80640.b", (3, 3, 4): "864.4673", (3, 7): "30240.b", (4, 6): "17280.g", (5, 5): "14400.bg"},
    11: {(2, 2, 2, 2, 3): "96.230", (2, 2, 2, 5): "960.11355", (2, 2, 3, 4): "576.8659", (2, 2, 7): "20160.l", (2, 3, 3, 3): "432.759", (2, 3, 6): "8640.t", (2, 4, 5): "5760.co", (2, 9): "725760.a", (3, 3, 5): "4320.bp", (3, 4, 4): "3456.jo", (3, 8): "241920.a", (4, 7): "120960.e", (5, 6): "86400.c"},
    # subgroup lists for degree 12 are incomplete
    # 12: {(2, 2, 2, 2, 2, 2): "64.267", (2, 2, 2, 2, 4): "384.20162", (2, 2, 2, 3, 3): "288.1040", (2, 2, 2, 6): "5760.ei", (2, 2, 3, 5): "2880.dt", (2, 2, 4, 4): "2304.er", (2, 2, 8): "161280.be", (2, 3, 3, 4): "1728.47874", (2, 3, 7): "60480.h", (2, 4, 6): "34560.f", (2, 5, 5): "28800.bz", (2, 10): "7257600.a", (3, 3, 3, 3): "1296.3538", (3, 3, 6): "25920.w", (3, 4, 5): "17280.bd", (3, 9): "2177280.a", (4, 4, 4): "13824.fn", (4, 8): "967680.e", (5, 7): "604800.b", (6, 6): "518400.r"}
}

# Uses the above HTML files to find all subgroup labels of the relevant direct product of symmetric groups

def extract_subgroup_labels(filename):
    subgroup_labels = []
    
    with open(filename, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    in_section = False
    section_lines = []
    for line in lines:
        # Start marker: look for "subgroup_profile" in the line.
        if not in_section and "subgroup_profile" in line:
            in_section = True
            # print("Start marker found:", line.rstrip())
        if in_section:
            section_lines.append(line)
        # End marker: look for "subgroup_autprofile" in the line.
        if in_section and "subgroup_autprofile" in line:
            # print("End marker found:", line.rstrip())
            break

    # print("Number of lines in the extracted section:", len(section_lines))

    # Regex pattern to match lines beginning with '<tr><td>Order ' allowing for leading whitespace.
    order_line_pattern = re.compile(r'^\s*<tr><td>Order (\d+)', re.IGNORECASE)

    for line in section_lines:
        order_match = order_line_pattern.search(line)
        if order_match:
            order_number = order_match.group(1)
            # Only consider order numbers greater than 500.
            # if int(order_number) > 500:
                # print("Processing order line:", line.rstrip())
                # Build regex for occurrences: kwargs="args=<order_number>.<y>%"
            pattern = re.compile(r'kwargs="args=(%s\.(?:[a-z]+|\d+))%%' % order_number)
            matches = pattern.findall(line)
            if matches:
                # print("Matches found:", matches)
                subgroup_labels.extend(matches)

    return subgroup_labels

# Now we check if the subgroups from the previous step are transitive subgroups of S_n, where n is a divisor from before
# First we find the transitivity degrees of each subgroup from the previous step
# Uses LMFDB's API; for example, to check the transitive degrees of group with label 6.1, we go to "https://beta.lmfdb.org/knowledge/show/lmfdb.object_information?args=6.1&func=trans_expr_data"
# Since LMFDB sorts transitive degrees in ascending order, we stop looking once the degree is too large
# For example, when 6 = 2 + 4 as above, the relevant transitive degrees are 4 and 8

def check_transitivity(x, y, transitive_degrees):
    # if x <= 500:
        # return False
    
    url = f"https://beta.lmfdb.org/knowledge/show/lmfdb.object_information?args={x}.{y}&func=trans_expr_data"
    # print(f"Checking URL: {url}")  # Debugging statement
    
    response = requests.get(url)
    if response.status_code != 200:
        print(f"Error fetching URL: {response.status_code}")
        return False
    
    html_content = response.text
    
    pattern = r'<a href="/GaloisGroup/(\d+)T'
    matches = re.findall(pattern, html_content)
    
    # Convert the matches to integers
    extracted_degrees = [int(match) for match in matches]
    extracted_degrees.sort()
    
    # print("Extracted degrees:", extracted_degrees)  # Debugging statement
    
    # Check for the transitive degrees in the extracted degrees
    found_degree = None
    for degree in transitive_degrees:
        # print(f"Checking for transitive degree {degree}...")  # Debugging statement
        for value in extracted_degrees:
            if value == degree:
                found_degree = degree
                # print(f"Transitive degree {degree} found!")  # Debugging statement
                return True
            elif value > degree:
                # print(f"Current value {value} exceeds transitive degree {degree}; moving to next transitive degree.")  # Debugging statement
                break
        if found_degree is not None:
            break
    
    if found_degree is None:
        # print("Subgroup {x}.{y} is not a transitive subgroup of the relevant degree.")  # Debugging statement
        return False

# Main function
# Print the final list of matches grouped by partition and then by transitive degree
# They are printed in the form x.y, which can be searched on LMFDB as before

def main():
    d = int(input("Degree 'd' of the polynomial (must be between 5 and 11, inclusive): "))
    if d < 5 or d > 11:
        raise ValueError("Degree must be between 5 and 11.")

    partitions = [p for p in accel_asc(d) if 1 not in p and d not in p]
    grouped_matches = {}

    # print(f"Partitions: {partitions}")

    for partition in partitions:
        D = prod(partition)
        divisors = get_transitive_subgroup_degrees(D, partition)

        # print(f"Partition: {partition}, D: {D}, Divisors: {divisors}")

        for m in divisors:
            label = lookup_table[d].get(tuple(partition))
            if label:
                x_y = label.replace('.', '_')
                file_path = f"C:\\Documents\\Python Code\\Thesis-Group Theory\\.venv\\lmfdb_{x_y}.txt"
                subgroups = extract_subgroup_labels(file_path)
                matches = set(subgroups)

                # print(f"Label: {label}, File Path: {file_path}, Subgroups: {subgroups}")

                if matches:
                    partition_key = tuple(partition)
                    if partition_key not in grouped_matches:
                        grouped_matches[partition_key] = {}
                    if m not in grouped_matches[partition_key]:
                        grouped_matches[partition_key][m] = []
                    grouped_matches[partition_key][m].extend(matches)

    output_file = 'automated_search_large_subgroups.txt'
    with open(output_file, 'w') as f:
        for partition, divisors in grouped_matches.items():
            f.write(f"Subgroups of the Product of Symmetric Groups: {partition}\n")
            printed_labels = set()
            for divisor, matches in sorted(divisors.items()):
                f.write(f"  Transitive Subgroups of: S_{divisor}\n")
                for match in sorted(matches, key=lambda x: (int(x.split('.')[0]), x.split('.')[1])):
                    if match not in printed_labels:
                        target_integers = [divisor]
                        try:
                            x = int(match.split('.')[0])
                            y = match.split('.')[1]
                        except ValueError:
                            print(f"Skipping non-numeric match: {match}")
                            continue
                        if check_transitivity(x, y, target_integers):
                            f.write(f"    {match}\n")
                            printed_labels.add(match)
            f.write("\n")

    print(f"Results written to {output_file}")

if __name__ == "__main__":
    main()