#!/bin/bash

# Path to the directory containing the textures
textures_dir="/workspaces/IllyriaRP/illyriarp/assets/custom/textures/painting"
# Path to the directory where the new JSON files will be saved
output_dir="/workspaces/IllyriaRP/illyriarp/assets/custom/models/painting"

# Ensure the output directory exists
mkdir -p "$output_dir"

# Base JSON structure
base_json='{
  "parent": "item/generated",
  "textures": { "layer0": "custom:painting/PLACEHOLDER" }
}'

# Iterate over each texture file in the directory
for texture_file in "$textures_dir"/*.png; do
  texture_name=$(basename "$texture_file" .png)
  new_json=${base_json//PLACEHOLDER/$texture_name}
  
  # Write the new JSON to a file
  output_file_path="$output_dir/$texture_name.json"
  echo "$new_json" > "$output_file_path"
done

echo "JSON files created successfully."