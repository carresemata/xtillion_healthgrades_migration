import json
from collections import deque, defaultdict
import os

def read_json(file_path):
    print(os.getcwd())
    with open(file_path, 'r') as file:
        return json.load(file)

    
    # if len(sorted_order) != len(in_degree):
    #     raise Exception("There is a cycle in the graph")

def list_contains(list1, list2):
    # Create a set from list1 for faster lookups
    set1 = set(list1)
    
    # Check if every element in list2 is in list1
    for element in list2:
        if element not in set1:
            return False
    
    # If all elements in list2 are found in list1
    return True
    
def main():
    # Read the JSON file
    file_path = 'sp_dependencies.json'
    dependencies = read_json(file_path)
    conditions_met = []
    count = 1

    while len(conditions_met) < len(dependencies.keys()):
        print(f'Round: {count}')
        # print(conditions_met)
        for key in dependencies:
            if list_contains(conditions_met,dependencies[key]) and key not in conditions_met:
                conditions_met.append(key)
        count += 1
    
    for proc in conditions_met:
        schema,table = proc.split('.')
        print(f'call {schema}.{table}(TRUE);')


    # Print the sorted operations

if __name__ == "__main__":
    main()