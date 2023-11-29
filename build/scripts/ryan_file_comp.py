import os
import re

BENCHMARKS_PATH = "../../../rv32-benchmarks/"
# PROGRAM_TESTED = "post-synth-sim"
PROGRAM_TESTED = "routed-sim"

trace_line_syntax = re.compile(f"\\[W\\]\\s+[0-9a-f]{{8}}\\s+(0|1)\\s+[0-9a-f]{{2}}\\s+[0-9a-f]{{8}}")


# returns a tuple of 2 values
# first value is 1 if passed, 0 if failed
# secodnd value is a string containing the outcome
def get_status(benchmark_path, file_path, file_name):
    with open(f"{benchmark_path}{file_name}.d") as fin :
        lines = fin.readlines()
    pass_loc = -1
    fail_loc = -1
    for k,line in enumerate(lines) :
        if line.find( "<pass>" ) != -1 :
            pass_loc = k
        if line.find( "<fail>" ) != -1 :
            fail_loc = k
    if pass_loc == -1 or fail_loc == -1:
        return 0, "Unable to decode .d file"
    pass_loc = lines[pass_loc][0:8]
    fail_loc = lines[fail_loc][0:8]
    pass_fetch = re.compile(f"\\[W\\]\\s*{pass_loc}")
    fail_fetch = re.compile(f"\\[W\\]\\s*{fail_loc}")
    fail_nop_fetch = re.compile(f"\\[W\\]\\s*{fail_loc} (0|1 00 00000000)")

    with open(f"{file_path}{file_name}.trace") as fin :
        lines = fin.readlines()
    for line in lines:
        if(fail_fetch.search(line) and fail_nop_fetch.search(line) == None):
            return 0, "FAIL"
    for line in lines:
        if(pass_fetch.search(line)):
            return 1, "PASS"
    return 0, "Unable to find pass or fail criteria"



def compare_trace_files(file_a:str, file_b:str):
    differences = 0

    with open(file_a) as fin :
        a_lines = fin.readlines()
    with open(file_b) as fin :
        b_lines = fin.readlines()

    if(len(a_lines) < len(b_lines)):
        min_lines = len(a_lines)
        longer_file = b_lines       # was used in code at bottom of function
    elif(len(a_lines) > len(b_lines)):
        min_lines = len(b_lines)
        longer_file = a_lines       # was used in code at bottom of function
    else:
        min_lines = len(a_lines)
        longer_file = []            # was used in code at bottom of function
    
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
            #    print(f"Difference on line {i+1}: line a: {a_lines[i][0:-2]}, line b: {b_lines[i][0:-2]}")
               differences += 1

    # These commented lines check if there are any funtional lines in one file after the other file ends.
    # This isn't useful as execution after the end of the program is undefined so nothing can be concluded from it

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
    # print(f"Building bitstream for {program_name}")
    # os.system(f"make clean")
    # os.system(f"mkdir -p ryan_output/logs")
    # os.system(f"make bitstream MEM_PATH={program_path}{program_name}.x > ryan_output/logs/bitstream_{program_name}")
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
# os.system(f"make clean")
print(f"Building bitstream")
os.system(f"mkdir -p ryan_output/logs")
os.system(f"make bitstream > ryan_output/logs/bitstream.txt")


make_new_tcl(3000)
ind_total_tests = 0
ind_tests_passed = 0
ind_failed_tests = []
for file_name in ind_programs_names:
    run_build_program(file_name, f"{BENCHMARKS_PATH}individual-instructions/", PROGRAM_TESTED)

    parse_trace(source_file = f"../../verif/sim/verilator/test_pd/{file_name}.trace", dest_file = f"ryan_output/test_pd/{file_name}.trace", )

    diff = compare_trace_files(f"ryan_output/test_pd/{file_name}.trace", f"ryan_output/{PROGRAM_TESTED}/{file_name}.trace")
    if diff == 0:
        print(f"No differences detected for test {file_name}")
        ind_tests_passed += 1
    else:
        ind_failed_tests += [(file_name, diff)]
        print(f"{diff} differences detected for test {file_name}")
    ind_total_tests += 1


make_new_tcl(11000)
simple_total_tests = 0
simple_tests_passed = 0
simple_failed_tests = []
for file_name in simple_programs_names:
    run_build_program(file_name, f"{BENCHMARKS_PATH}simple-programs/", PROGRAM_TESTED)

    # parse_trace(source_file = f"../../verif/sim/verilator/test_pd/{file_name}.trace", dest_file = f"ryan_output/test_pd/{file_name}.trace", )

    diff = compare_trace_files(f"ryan_output/test_pd/{file_name}.trace", f"ryan_output/{PROGRAM_TESTED}/{file_name}.trace")
    if diff == 0:
        print(f"No differences detected for test {file_name}")
        simple_tests_passed += 1
    else:
        simple_failed_tests += [(file_name, diff)]
        print(f"{diff} differences detected for test {file_name}")
    simple_total_tests += 1




print("-----------------------------------------------------------------------")
print(f"Passed: {ind_tests_passed}/{ind_total_tests}")
if ind_total_tests - ind_tests_passed > 0:
    print("Failed Tests:")
    for i in range(ind_total_tests - ind_tests_passed):
        print(f"{ind_failed_tests[i][1]} differences detected for test {ind_failed_tests[i][0]}")
print("-----------------------------------------------------------------------")

ind_total_tests = 0
ind_tests_passed = 0
for file_name in ind_programs_names:
    result = get_status(f"{BENCHMARKS_PATH}individual-instructions/", f"ryan_output/{PROGRAM_TESTED}/", file_name)
    print(f"Program: {file_name},   \tStatus: {result[1]}")
    ind_tests_passed += result[0]
    ind_total_tests += 1
print(f"Passed: {ind_tests_passed}/{ind_total_tests}")

print("-----------------------------------------------------------------------")
print(f"Passed: {simple_tests_passed}/{simple_total_tests}")
if simple_total_tests - simple_tests_passed > 0:
    print("Failed Tests:")
    for i in range(simple_total_tests - simple_tests_passed):
        print(f"{simple_failed_tests[i][1]} differences detected for test {simple_failed_tests[i][0]}")
print("-----------------------------------------------------------------------")

simple_total_tests = 0
simple_tests_passed = 0
for file_name in simple_programs_names:
    result = get_status(f"{BENCHMARKS_PATH}simple-programs/", f"ryan_output/{PROGRAM_TESTED}/", file_name)
    print(f"Program: {file_name},   \tStatus: {result[1]}")
    simple_tests_passed += result[0]
    simple_total_tests += 1
print(f"Passed: {simple_tests_passed}/{simple_total_tests}")
