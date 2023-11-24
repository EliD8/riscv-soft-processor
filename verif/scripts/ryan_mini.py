# This program runs the scripts and verifies the output
import os
import re
PATH = "../../../rv32-benchmarks/"
test_passed = 0
total_tests = 0

def run_programs(path, programs):
    program = programs[0]
    program_path = os.path.join(path, program)
    os.system(f"make run MEM_PATH={program_path}")
    print(f"Executing {program}...")

def get_status(path, p):
    with open(f"{path}{p}.d") as fin :
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

    with open(f"../sim/verilator/test_pd/{p}.trace") as fin :
        lines = fin.readlines()
    for line in lines:
        if(fail_fetch.search(line)):
            return 0, "FAIL"
    for line in lines:
        if(pass_fetch.search(line)):
            return 1, "PASS"
    return 0, "Unable to find pass or fail criteria"



files = os.listdir(f"{PATH}individual-instructions/")
ind_programs = [file for file in files if file.endswith('.x')]
run_programs(f"{PATH}individual-instructions/", ind_programs)

files = os.listdir(f"{PATH}simple-programs/")
sim_programs = [file for file in files if file.endswith('.x')]
run_programs(f"{PATH}simple-programs/", sim_programs)

p_list = [os.path.splitext(p)[0] for p in ind_programs]
p = p_list[0]
result = get_status(f"{PATH}individual-instructions/", p)
print(f"Program: {p},   \tStatus: {result[1]}")
test_passed += result[0]
total_tests += 1
print(f"Passed: {test_passed}/{total_tests}")
test_passed = 0
total_tests = 0


sp_list = [os.path.splitext(p)[0] for p in sim_programs]
p = sp_list[0]
result = get_status(f"{PATH}simple-programs/", p)
print(f"Program: {p},   \tStatus: {result[1]}")
test_passed += result[0]
total_tests += 1

print(f"Passed: {test_passed}/{total_tests}")