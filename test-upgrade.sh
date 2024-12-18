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
CHARTS=$(yq -r '.charts[] | .chart + " " + .version' "$CONFIG_FILE")
PACKAGES_DIR="./.packages"

# Loop through each chart and process it
while IFS= read -r CHART_VERSION; do
    CHART=$(echo "$CHART_VERSION" | awk '{print $1}')  # Chart name
    VERSION=$(echo "$CHART_VERSION" | awk '{print $2}')  # Desired version

    echo "Processing chart: $CHART"
    echo "Upgrading to version: $VERSION"
    if helm show chart "$CHART" --version "$VERSION" >/dev/null 2>&1; then
        echo "Version $VERSION for $CHART found. Proceeding..."
         helm pull "$CHART" --version "$VERSION" -d "$PACKAGES_DIR"
         helm repo index "$PACKAGES_DIR" --url https://omegnet.github.io/helm_charts/ 
    else
        echo "Version $VERSION for $CHART not found. Skipping..."
        continue
    fi
    #  # Check if the chart has been updated
    # if git diff --name-only HEAD^ HEAD | grep -q "charts/$CHART"; then
    #     echo "Chart $CHART has been updated. Creating release..."
    #     helm package "./charts/$CHART"
    #     helm repo index . --url https://github.com/${{ github.repository }}/releases

    #     # Create a new GitHub release
    #     TAG_NAME="$CHART"  # Use the chart name as the tag
    #     echo "Creating release for $TAG_NAME..."
    #     curl -s -X POST -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
    #     -H "Accept: application/vnd.github+json" \
    #     https://api.github.com/repos/${{ github.repository }}/releases \
    #     -d '{
    #         "tag_name": "'"$TAG_NAME"'",
    #         "name": "'"$TAG_NAME"'",
    #         "body": "Automated release for '"$CHART"'",
    #         "draft": false,
    #         "prerelease": false
    #     }'
    # else
    #     echo "No changes detected for $CHART. Skipping release creation."
    # fi
done <<< "$CHARTS"

echo "Upgrade test completed."
