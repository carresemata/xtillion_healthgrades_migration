# This script generates the main_proc_script.txt file which contains the list of stored procedures to be called in the main procedure

import os
import json

dependencies = []

with open('sp_dependencies.json', 'r') as f:
    sp_dependencies = json.loads(f.read())

count = 1
while len(dependencies) < len(sp_dependencies):
    print(f'--------------Iteration {count}--------------')
    for sp, sp_deps in sp_dependencies.items():
        dependency_found = True  # Assume all dependencies are found initially
        for dep in sp_deps:
            if dep not in dependencies:
                dependency_found = False  # Set to False if any dependency is not found
                break  # No need to check further dependencies for this sp
        if dependency_found and sp not in dependencies:
            print(f'--Adding {sp}')
            dependencies.append(sp)
    count += 1
    if count > 100:
        break

set_dependencies = set(dependencies)
set_sp_dependencies = set(sp_dependencies.keys())

if set_dependencies != set_sp_dependencies:
    print('Some dependencies are missing')
    print(set_sp_dependencies - set_dependencies)

with open('main_proc_script.txt','w') as f:
    for sp in dependencies:
        f.write(f'CALL {sp}(:is_full);\n')