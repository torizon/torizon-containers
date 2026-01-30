def modify_paths(file_path):
    # Define the replacements as a dictionary
    replacements = {
        '/content/images/all': 'images/all',
        '/content/images/train': 'images/train',
        '/content/images/validation': 'images/validation',
        '/content/images/test': 'images/test'
    }

    # Read the file content
    with open(file_path, 'r') as file:
        content = file.read()

    # Replace the paths
    for old_path, new_path in replacements.items():
        content = content.replace(old_path, new_path)

    # Write the updated content back to the file
    with open(file_path, 'w') as file:
        file.write(content)

file_path = 'train_val_test_split.py'
modify_paths(file_path)