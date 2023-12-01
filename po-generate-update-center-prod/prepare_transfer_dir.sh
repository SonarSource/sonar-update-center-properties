#!/bin/bash 
set -euo pipefail

: "${OUTPUT_DIR?}"
: "${OUTPUT_DIR_ALL_VERSIONS?}"

TRANSFER_DIR=$(mktemp -d -p "$PWD" -t tranfer.XXXXXXXX)
trap 'rm -rf "$TRANSFER_DIR"' EXIT

echo "Prepare files for transfer into $TRANSFER_DIR"
PLUGINS_DIR=$TRANSFER_DIR/plugins
mkdir "$PLUGINS_DIR"

# transfer set #1, update-center.properties
cp "$OUTPUT_DIR/sonar-updates.properties" "$TRANSFER_DIR/update-center.properties"

# transfer set #2, copy html to plugins
cp "$OUTPUT_DIR"/html/*.* "$PLUGINS_DIR/"

# transfer set #3, copy to sonarsource.com wp-content is deprecated

# transfer set #4, copy editions.json to update.sonarsource.org root does not exist anymore

# transfer set #5, copy editions.html to update.sonarsource.org root does not exist anymore

# transfer set #6, the file style-confluence.css does not exist anymore

# transfer set #7 copy json to update.sonarsource.org root
cp "$OUTPUT_DIR"/json/*.* "$TRANSFER_DIR/"

# transfer sonar-updates.properties all versions
cp "$OUTPUT_DIR_ALL_VERSIONS/sonar-updates.properties" "$TRANSFER_DIR/update-center-all-versions.properties"
echo "Prepare done"

trap - EXIT
export TRANSFER_DIR
