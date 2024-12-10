#!/bin/bash

set -e  # Exit on any error

# Specify chart versions
echo "Reading specified chart versions..."
CONFIG_FILE="./chart-versions.yaml"

# Ensure the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE not found! Exiting..."
    exit 1
fi

# Read the chart_versions.yaml file using yq
CHARTS=$(yq '.charts[]' "$CONFIG_FILE" | jq -rc '.chart + " " + .version')

# Loop through each chart and process it
while IFS= read -r CHART_VERSION; do
    CHART=$(echo "$CHART_VERSION" | awk '{print $1}')  # Chart name
    VERSION=$(echo "$CHART_VERSION" | awk '{print $2}')  # Desired version

    echo "Processing chart: $CHART"
    echo "Upgrading to version: $VERSION"

    # Check if the specified version exists
    if helm show chart "$CHART" --version "$VERSION" >/dev/null 2>&1; then
        echo "Version $VERSION for $CHART found. Proceeding..."
        # Uncomment the following lines to perform the actual operations
        helm pull "$CHART" --version "$VERSION"
        helm repo index . --merge index.yaml
    else
        echo "Version $VERSION for $CHART not found. Skipping..."
        continue
    fi
done <<< "$CHARTS"

echo "Upgrade test completed."
