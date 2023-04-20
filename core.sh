#!/bin/bash

# Function to validate input
validate_input() {
  if [[ "$1" =~ ^[a-zA-Z0-9\ ]+$ ]]; then
    return 0
  else
    return 1
  fi
}

# Read races from the input Markdown file (races.md)
races=()
descriptions=()
header_row=1

while IFS='|' read -r _ race description _; do
    if [[ $header_row -eq 1 ]]; then
        header_row=0
    elif [[ $race != " Race " ]] && [[ $race != "------------" ]]; then
        races+=("${race//[[:space:]]/}")
        descriptions+=("${description//[[:space:]]/}")
    fi
done < races.md

# Ask for the user's name and PC name
while true; do
  read -p "Enter your name: " name
  if validate_input "$name"; then
    break
  else
    echo "Invalid input. Please enter only alphanumeric characters and spaces."
  fi
done

while true; do
  read -p "Enter your PC name: " pc_name
  if validate_input "$pc_name"; then
    break
  else
    echo "Invalid input. Please enter only alphanumeric characters and spaces."
  fi
done

# Replace spaces with underscores in the user's name and PC name
name=${name// /_}
pc_name=${pc_name// /_}

# Get the current date in the desired format
date_str=$(date +"%Y-%m-%d")

# Create the file with the specified naming convention
file_name="Finished_PCs/${date}-${name// /_}-${pc_name// /_}.md"

# Create the file and add the user's information
echo "Name: $name" > $file_name
echo "PC Name: $pc_name" >> $file_name

# Display race options
echo "Select your PC race:"
for i in "${!races[@]}"; do
    echo "$((i+1)). ${races[i]}"
done

# Ask for the user's choice and save the corresponding description
read -p "Enter the number of your choice: " choice
choice=$((choice-1))
echo "Race: ${races[choice]}" >> $file_name
echo "Description: ${descriptions[choice]}" >> $file_name

# Include the information from the corresponding race Markdown file
race_file="Race/${races[choice]}.md"
if [[ -f $race_file ]]; then
    echo "Race Information:" >> $file_name
    cat "$race_file" >> $file_name
else
    echo "No race-specific information found." >> $file_name
fi

# Read homelands
homelands=()
homeland_dirs=()

for homeland in Homelands/*; do
  if [[ -d "$homeland" ]]; then
    homeland_name=$(basename "$homeland")
    homelands+=("$homeland_name")
    homeland_dirs+=("$homeland")
  fi
done

# Display homeland options
echo "Select your homeland:"
for i in "${!homelands[@]}"; do
    echo "$((i+1)). ${homelands[i]}"
done
echo "$(( ${#homelands[@]} + 1 )). Random"

# Ask for the user's choice and save the corresponding homeland or pick a random one
read -p "Enter the number of your choice: " choice
if [[ $choice -eq $(( ${#homelands[@]} + 1 )) ]]; then
  choice=$((RANDOM % ${#homelands[@]} + 1))
fi
chosen_homeland=${homelands[$((choice-1))]}
chosen_homeland_dir=${homeland_dirs[$((choice-1))]}
echo "Homeland: $chosen_homeland" >> $file_name

# Read nations
nations=()
nation_dirs=()

for nation in "$chosen_homeland_dir"/*; do
  if [[ -d "$nation" ]]; then
    nation_name=$(basename "$nation")
    nations+=("$nation_name")
    nation_dirs+=("$nation")
  fi
done

# Display nation options
echo "Select your nation:"
for i in "${!nations[@]}"; do
    echo "$((i+1)). ${nations[i]}"
done
echo "$(( ${#nations[@]} + 1 )). Random"

# Ask for the user's choice and save the corresponding nation or pick a random one
read -p "Enter the number of your choice: " choice
if [[ $choice -eq $(( ${#nations[@]} + 1 )) ]]; then
  choice=$((RANDOM % ${#nations[@]} + 1))
fi
chosen_nation=${nations[$((choice-1))]}
chosen_nation_dir=${nation_dirs[$((choice-1))]}
echo "Nation: $chosen_nation" >> $file_name

# Read settlements
settlements=()
settlement_files=()

for settlement in "$chosen_nation_dir"/*.md; do
  if [[ -f "$settlement" ]]; then
    settlement_name=$(basename "$settlement" .md)
    settlements+=("$settlement_name")
    settlement_files+=("$settlement")
  fi
done

# Display settlement options
echo "Select your settlement:"
for i in "${!settlements[@]}"; do
    echo "$((i+1)). ${settlements[i]}"
done
echo "$(( ${#settlements[@]} + 1 )). Random"

# Ask for the user's choice and save the corresponding settlement or pick a random one
read -p "Enter the number of your choice: " choice
if [[ $choice -eq $(( ${#settlements[@]} + 1 )) ]]; then
  choice=$((RANDOM % ${#settlements[@]} + 1))
fi
chosen_settlement=${settlements[$((choice-1))]}
chosen_settlement_file=${settlement_files[$((choice-1))]}
echo "Settlement: $chosen_settlement" >> $file_name

# Include the information from the corresponding settlement Markdown file
if [[ -f $chosen_settlement_file ]]; then
    echo "Settlement Information:" >> $file_name
    cat "$chosen_settlement_file" >> $file_name
else
    echo "No settlement-specific information found." >> $file_name
fi

# Read backgrounds
backgrounds=()
background_files=()

for background in Backgrounds/*.md; do
  if [[ -f "$background" ]]; then
    background_name=$(basename "$background" .md)
    backgrounds+=("$background_name")
    background_files+=("$background")
  fi
done

# Display background options
echo "Select your background:"
for i in "${!backgrounds[@]}"; do
    echo "$((i+1)). ${backgrounds[i]}"
done

# Ask for the user's choice and save the corresponding background
read -p "Enter the number of your choice: " choice
choice=$((choice-1))
chosen_background=${backgrounds[choice]}
chosen_background_file=${background_files[choice]}
echo "Background: $chosen_background" >> $file_name

# Include the information from the corresponding background Markdown file
if [[ -f $chosen_background_file ]]; then
    echo "Background Information:" >> $file_name
    cat "$chosen_background_file" >> $file_name
else
    echo "No background-specific information found." >> $file_name
fi

# Read rivals and allies from the chosen background Markdown file
rivals=0
allies=0

while IFS='|' read -ra line; do
    key="${line[0]//[[:space:]]/}"
    value="${line[1]//[[:space:]]/}"

    if [[ $key == "Rivals" ]]; then
        rivals=$value
    elif [[ $key == "Allies" ]]; then
        allies=$value
    fi
done < "$chosen_background_file"

# Add rival and ally numbers to the output file
echo "Rivals: $rivals" >> $file_name
echo "Allies: $allies" >> $file_name

# Powerful Family Relationships
echo "Enter a number for poertful family relationships or type 'roll' to roll a 1d6 divided by 2 (rounded down, minimum 1):"

# Rolling for Family Relationship number
read input
if [ "$input" == "roll" ]; then
  roll_result=$(( (RANDOM % 6) + 1 ))
  num_relationships=$(( (roll_result / 2) ))
  if [ $num_relationships -lt 1 ]; then
    num_relationships=1
  fi
else
  num_relationships=$input
fi

for ((i=1; i<=num_relationships; i++)); do
  # Select a random ally and rival
  ally_file=$(find Powerful_Family_Relationship/Family_Ally -type f | shuf -n 1)
  rival_file=$(find Powerful_Family_Relationship/Family_Rivals -type f | shuf -n 1)

  # Add the ally and rival information to the output file
  echo "Family Relationship $i" >> $file_name
  echo "Ally:" >> $file_name
  cat "$ally_file" >> $file_name
  echo "Rival:" >> $file_name
  cat "$rival_file" >> $file_name

  # Select a random identity
  identity_file=$(find NPC_Identities -type f | shuf -n 1)
  identity_name=$(basename "$identity_file" .md)

  # Check if the identity has a "+1" in its name
  if [[ $identity_name == *"+1"* ]]; then
    # Select a random fateful moment
    fateful_moment_file=$(find Fateful_Moments -type f | shuf -n 1)
    echo "Fateful Moment:" >> $file_name
    cat "$fateful_moment_file" >> $file_name
  fi
done

# Replace underscores with spaces in the output file
awk '{gsub(/_/," "); print}' $file_name > temp_file.md
mv temp_file.md $file_name

# Print the generated file name and its contents
echo "Generated file: $file_name"
echo "File contents:"
cat $file_name
echo "That is all."