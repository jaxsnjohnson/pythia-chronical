#!/bin/bash

echo "Welcome to the PC background generator!"
echo "Please enter your name:"
read name
echo "Please enter your PC's name:"
read pc_name

# Get the current date and format it as yyyy-mm-dd
date=$(date +'%Y-%m-%d')

# Generate the filename using the naming convention
filename="$date-$name-$pc_name.md"

# Create the file and write the content
echo "# $pc_name's Pythia Chronicle" > "$filename"
echo "## $name $date" >> "$filename"

echo "Thank you, $name! Your PC background has been generated and saved to $filename."
