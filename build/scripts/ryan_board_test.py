import os
import re

BENCHMARKS_PATH = "../../../rv32-benchmarks/"

trace_line_syntax = re.compile(f"\\[W\\]\\s+[0-9a-f]{{8}}\\s+(0|1)\\s+[0-9a-f]{{2}}\\s+[0-9a-f]{{8}}")


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

    with open(f"{file_path}{file_name}.trace") as fin :
        lines = fin.readlines()
    for line in lines:
        if(fail_fetch.search(line)):
            return 0, "FAIL"
    for line in lines:
        if(pass_fetch.search(line)):
            return 1, "PASS"
    return 0, "Unable to find pass or fail criteria"


all_ind_files = os.listdir(f"{BENCHMARKS_PATH}individual-instructions/")
ind_programs_files = [file for file in all_ind_files if file.endswith('.x')]
ind_programs_names = [os.path.splitext(p)[0] for p in ind_programs_files]

all_simple_files = os.listdir(f"{BENCHMARKS_PATH}simple-programs/")
simple_programs_files = [file for file in all_simple_files if file.endswith('.x')]
simple_programs_names = [os.path.splitext(p)[0] for p in simple_programs_files]

os.system(f"mkdir -p ryan_output")
os.system(f"mkdir -p ryan_output/board_output")
os.system(f"mkdir -p ryan_output/board_output_logs")

for file_name in ind_programs_names:
    print(f"building {file_name}")
    os.system(f"cp {BENCHMARKS_PATH}individual-instructions/{file_name}.x ../to_pynq")
    os.system(f"make check MEM_PATH=../to_pynq/{file_name}.x > ryan_output/board_output_logs/{file_name}.txt")
    os.system(f"mv {file_name}.trace ryan_output/board_output")

for file_name in simple_programs_names:
    print(f"building {file_name}")
    os.system(f"cp {BENCHMARKS_PATH}simple-programs/{file_name}.x ../to_pynq")
    os.system(f"make check MEM_PATH=../to_pynq/{file_name}.x > ryan_output/board_output_logs/{file_name}.txt")
    os.system(f"mv {file_name}.trace ryan_output/board_output")


print("-----------------------------------------------------------------------")

ind_total_tests = 0
ind_tests_passed = 0
for file_name in ind_programs_names:
    result = get_status(f"{BENCHMARKS_PATH}individual-instructions/", f"ryan_output/board_output/", file_name)
    print(f"Program: {file_name},   \tStatus: {result[1]}")
    ind_tests_passed += result[0]
    ind_total_tests += 1
print(f"Passed: {ind_tests_passed}/{ind_total_tests}")

print("-----------------------------------------------------------------------")

simple_total_tests = 0
simple_tests_passed = 0
for file_name in simple_programs_names:
    result = get_status(f"{BENCHMARKS_PATH}simple-programs/", f"ryan_output/board_output/", file_name)
    print(f"Program: {file_name},   \tStatus: {result[1]}")
    simple_tests_passed += result[0]
    simple_total_tests += 1
print(f"Passed: {simple_tests_passed}/{simple_total_tests}")

print("-----------------------------------------------------------------------")