#!/bin/bash

# Directory containing XML files
xml_dir="images/all"

# Extract names from XML files
sorted_names=$(grep -h "<name>.*</name>" "$xml_dir"/*.xml | sed 's/<name>\(.*\)<\/name>/\1/' | sort | uniq | sed 's/\t//g')

# Print sorted names
echo "$sorted_names" >labelmap.txt
