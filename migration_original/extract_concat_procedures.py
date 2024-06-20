import os

def concatenate_files_in_directory(source_base_dir, destination_dir):
    # Create the destination directory if it doesn't exist
    if not os.path.exists(destination_dir):
        os.makedirs(destination_dir)
    
    # Iterate through each directory in the source base directory
    for dir_name in os.listdir(source_base_dir):
        # Construct the full path to the subdirectory
        sub_dir_path = os.path.join(source_base_dir, dir_name)
        # Ensure it's a directory
            # List all files in the subdirectory
        for table in os.listdir(sub_dir_path):
            files = os.listdir(os.path.join(sub_dir_path, table))
            # print(files)
            for file in files:
                if 'original' in file:
                    file1_path = os.path.join(sub_dir_path, table,file)
                elif 'translated' in file:
                    file2_path = os.path.join(sub_dir_path,table, file)
                
                # Read the contents of the two files
            with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
                file1_contents = file1.read()
                file2_contents = file2.read()
                
            #     # Concatenate the contents
            concatenated_contents = '---------------ORIGINAL---------------\n'+ file1_contents +'\n---------------TRANSLATED---------------\n'+ file2_contents
                
            #     # Create the output file path
            concatenated_file_path = os.path.join(destination_dir, f"{dir_name}_{table}.txt")
                
            #     # Write the concatenated contents to the new file
            with open(concatenated_file_path, 'w') as concatenated_file:
                concatenated_file.write(concatenated_contents)
            
            print(f"Concatenated files from {sub_dir_path} into {concatenated_file_path}")


# Example usage
source_base_dir = 'ODS1Stage/tables'
destination_dir = 'procedure_translations'

concatenate_files_in_directory(source_base_dir, destination_dir)