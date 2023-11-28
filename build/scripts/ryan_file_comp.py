import os
import re

BENCHMARKS_PATH = "../../../rv32-benchmarks/"

trace_line_syntax = re.compile(f"\\[W\\]\\s+[0-9a-f]{{8}}\\s+(0|1)\\s+[0-9a-f]{{2}}\\s+[0-9a-f]{{8}}")

def compare_trace_files(file_a:str, file_b:str):
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



# Parses source_program and extracts all [W] lines into dest_file
# Will overwrite dest_file if it alreaddy exists
def parse_trace(source_file:str, dest_file:str):
    with open(source_file) as temp_file :
        temp_lines = temp_file.readlines()

    outlines = []
    for temp_line in temp_lines:
        if trace_line_syntax.match(temp_line):
            outlines += [temp_line]

    while outlines[0][4:12] == "00000000":
        outlines.pop(0)

    with open(dest_file, "w") as outfile:
        for line in outlines:
            outfile.write(line)



def run_build_program(program_name: str, program_path:str, command: str):
    print(f"Building bitstream for {program_name}")
    os.system(f"make clean")
    os.system(f"mkdir -p ryan_output/logs")
    os.system(f"make bitstream MEM_PATH={program_path}{program_name}.x > ryan_output/logs/bitstream_{program_name}")
    print(f"Running {command} for {program_name}")
    os.system(f"mkdir -p ryan_output/{command}")
    os.system(f"make {command} MEM_PATH={program_path}{program_name}.x > ryan_output/{command}/temp.trace")

    parse_trace(source_file=f"ryan_output/{command}/temp.trace", dest_file=f"ryan_output/{command}/{program_name}.trace")

    os.system(f"rm ryan_output/{command}/temp.trace")


def make_new_tcl(time: int):
    os.system(f"echo \"run {time}ns\" > xsim.tcl")
    os.system(f"echo \"exit\" >> xsim.tcl")


all_ind_files = os.listdir(f"{BENCHMARKS_PATH}individual-instructions/")
ind_programs_files = [file for file in all_ind_files if file.endswith('.x')]
ind_programs_names = [os.path.splitext(p)[0] for p in ind_programs_files]

all_simple_files = os.listdir(f"{BENCHMARKS_PATH}simple-programs/")
simple_programs_files = [file for file in all_simple_files if file.endswith('.x')]
simple_programs_names = [os.path.splitext(p)[0] for p in simple_programs_files]

os.system(f"mkdir -p ryan_output")
os.system(f"mkdir -p ryan_output/test_pd")

make_new_tcl(2000)
ind_total_tests = 0
ind_tests_passed = 0
ind_failed_tests = []
for file_name in ind_programs_names:
    break
    # run_build_program(file_name, f"{BENCHMARKS_PATH}individual-instructions/", "post-synth-sim")
    # run_build_program(file_name, f"{BENCHMARKS_PATH}individual-instructions/", "routed-sim")

    # parse_trace(source_file = f"../../verif/sim/verilator/test_pd/{file_name}.trace", dest_file = f"ryan_output/test_pd/{file_name}.trace", )

    diff = compare_trace_files(f"ryan_output/test_pd/{file_name}.trace", f"ryan_output/post-synth-sim/{file_name}.trace")
    if diff == 0:
        print(f"No differences detected for test {file_name}")
        ind_tests_passed += 1
    else:
        ind_failed_tests += [(file_name, diff)]
        print(f"{diff} differences detected for test {file_name}")
    ind_total_tests += 1


make_new_tcl(10000)
simple_total_tests = 0
simple_tests_passed = 0
simple_failed_tests = []
for file_name in simple_programs_names:
    # run_build_program(file_name, f"{BENCHMARKS_PATH}simple-programs/", "post-synth-sim")
    # run_build_program(file_name, f"{BENCHMARKS_PATH}simple-programs/", "routed-sim")

    # parse_trace(source_file = f"../../verif/sim/verilator/test_pd/{file_name}.trace", dest_file = f"ryan_output/test_pd/{file_name}.trace", )

    diff = compare_trace_files(f"ryan_output/test_pd/{file_name}.trace", f"ryan_output/post-synth-sim/{file_name}.trace")
    if diff == 0:
        print(f"No differences detected for test {file_name}")
        simple_tests_passed += 1
    else:
        simple_failed_tests += [(file_name, diff)]
        print(f"{diff} differences detected for test {file_name}")
    simple_total_tests += 1
    break




print("-----------------------------------------------------------------------")
print(f"Passed: {ind_tests_passed}/{ind_total_tests}")
if ind_total_tests - ind_tests_passed > 0:
    print("Failed Tests:")
    for i in range(ind_total_tests - ind_tests_passed):
        print(f"{ind_failed_tests[i][1]} differences detected for test {ind_failed_tests[i][0]}")
print("-----------------------------------------------------------------------")

print("-----------------------------------------------------------------------")
print(f"Passed: {simple_tests_passed}/{simple_total_tests}")
if simple_total_tests - simple_tests_passed > 0:
    print("Failed Tests:")
    for i in range(simple_total_tests - simple_tests_passed):
        print(f"{simple_failed_tests[i][1]} differences detected for test {simple_failed_tests[i][0]}")
print("-----------------------------------------------------------------------")


