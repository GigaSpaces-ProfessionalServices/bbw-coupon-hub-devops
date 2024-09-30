#!/bin/bash

# Check if exactly 3 arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <version1> <version2> <yaml_file>"
  exit 1
fi

VERSION1=$1
VERSION2=$2
YAML_FILE=$3

# Check if the provided YAML file exists
if [ ! -f "$YAML_FILE" ]; then
  echo "Error: YAML file '$YAML_FILE' not found!"
  exit 1
fi

# Function to get images from a Helm release
get_images() {
  local version=$1
  local yaml_file=$2
  helm template release dih/dih --version="$version" -f "$yaml_file" |
  grep "image:" |
  awk '{print $2}' |
  tr -d '"' |
  grep -v '^image:$' |
  awk '!seen[$0]++' |
  grep -v '^$' |
  grep -v 'warning:'
}

# Get images for both versions
IMAGES1=$(get_images "$VERSION1" "$YAML_FILE")
IMAGES2=$(get_images "$VERSION2" "$YAML_FILE")

# Convert images to arrays
IFS=$'\n' read -rd '' -a IMAGES1_ARRAY <<< "$IMAGES1"
IFS=$'\n' read -rd '' -a IMAGES2_ARRAY <<< "$IMAGES2"

# Print images that are in version1 but not in version2
echo "Images in version $VERSION1 but not in version $VERSION2:"
for img in "${IMAGES1_ARRAY[@]}"; do
  if ! [[ " ${IMAGES2_ARRAY[*]} " == *" $img "* ]]; then
    echo "$img"
  fi
done

# Print images that are in version2 but not in version1
echo "Images in version $VERSION2 but not in version $VERSION1:"
for img in "${IMAGES2_ARRAY[@]}"; do
  if ! [[ " ${IMAGES1_ARRAY[*]} " == *" $img "* ]]; then
    echo "$img"
  fi
done
