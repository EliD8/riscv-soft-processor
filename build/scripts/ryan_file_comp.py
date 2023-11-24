import os
import re


def compare_trace_files(file_a, file_b):
    differences = 0

    with open(file_a) as fin :
        a_lines = fin.readlines()
    with open(file_b) as fin :
        b_lines = fin.readlines()

    if(len(a_lines) < len(b_lines)):
        min_lines = len(a_lines)
        longer_file = b_lines
    elif(len(a_lines) > len(b_lines)):
        min_lines = len(b_lines)
        longer_file = a_lines
    else:
        min_lines = len(a_lines)
        longer_file = []
    
    line_writeback = re.compile(f"\\[W\\]\\s+[0-9a-f]+\\s+")
    line_rd = re.compile(f"\\[W\\]\\s+[0-9a-f]+\\s+(0|1)\\s+")
    for i in range(min_lines):
        line_a_writeback_match = line_writeback.match(a_lines[i])
        if line_a_writeback_match == None:
            print(f"Failed to decode file {file_a} on line {i}")
        line_a_writeback = a_lines[i][line_a_writeback_match.span()[1] : line_a_writeback_match.span()[1]+1]
        line_a_rd_match = line_rd.match(a_lines[i])
        if line_a_rd_match == None:
            print(f"Failed to decode file {file_a} on line {i}")
        line_a_rd = a_lines[i][line_a_rd_match.span()[1] : line_a_rd_match.span()[1]+2]
        line_b_writeback_match = line_writeback.match(b_lines[i])
        if line_b_writeback_match == None:
            print(f"Failed to decode file {file_b} on line {i}")
        line_b_writeback = b_lines[i][line_b_writeback_match.span()[1] : line_b_writeback_match.span()[1]+1]
        line_b_rd_match = line_rd.match(b_lines[i])
        if line_b_rd_match == None:
            print(f"Failed to decode file {file_b} on line {i}")
        line_b_rd = b_lines[i][line_b_rd_match.span()[1] : line_b_rd_match.span()[1]+2]
        
        if((line_a_writeback != '0' and line_a_rd != "00") or (line_b_writeback != '0' and line_b_rd != "00")):
           if(not a_lines[i] == b_lines[i]):
               print(f"Difference on line {i+1}: line a: {a_lines[i][0:-2]}, line b: {b_lines[i][0:-2]}")
               differences += 1

    # for i in range(min_lines, len(longer_file)):
    #     line_writeback_match = line_writeback.match(longer_file[i])
    #     if line_writeback_match == None:
    #         print(f"Failed to decode file {longer_file} on line {i}")
    #     longer_line_writeback = longer_file[i][line_writeback_match.span()[1] : line_writeback_match.span()[1]+1]
    #     line_rd_match = line_rd.match(longer_file[i])
    #     if line_rd_match == None:
    #         print(f"Failed to decode file {longer_file} on line {i}")
    #     longer_line_rd = longer_file[i][line_rd_match.span()[1] : line_rd_match.span()[1]+2]

    #     if longer_line_writeback != '0' and longer_line_rd != "00":
    #         print(f"Function line {i+1} exists in one file and not other. Line: {longer_file[i][0:-2]}")
    #         differences += 1
    return differences


print("total differences: " + compare_trace_files("rv32ui-p-add.trace", "../ryan_out.txt"))