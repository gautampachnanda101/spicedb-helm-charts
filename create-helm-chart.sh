#!/bin/sh
set -e -x
echo "Fetching the latest 5 versions of spicedb-operator..."
source .env
versions=$(curl -s https://api.github.com/repos/authzed/spicedb-operator/tags --header "Accept: application/vnd.github+json" --header "Authorization: Bearer ${GITHUB_TOKEN}" | jq -r '.[].name' | sed 's/^v//' | sort  --version-sort | sed 's/^/v/')
echo "Found versions: $versions"

# Display the versions and prompt the user to choose one
echo "Available versions:"
echo "$versions"
echo "Please enter the version you want to convert to a Helm chart:"
read chosen_version

# Download the bundle for the chosen version
bundle_url="https://github.com/authzed/spicedb-operator/releases/download/$chosen_version/bundle.yaml"
echo "Downloading the bundle from $bundle_url..."
curl -L -o bundle.yaml $bundle_url

# Use helmify to convert the bundle to a Helm chart
echo "Converting the bundle to a Helm chart using helmify..."
rm -rf helm || true
mkdir -p helm
cd helm
rm -rf spicedb-operator || true && cat ../bundle.yaml |  helmify spicedb-operator -generate-defaults
echo "Setting the version and name in Chart.yaml..."
sed -i '' "s/^version:.*/version: $chosen_version/" spicedb-operator/Chart.yaml
sed -i '' "s/^name:.*/name: spicedb-operator/" spicedb-operator/Chart.yaml
# Package the Helm chart
echo "Packaging the Helm chart..."
helm package ./spicedb-operator -n spicedb-operator

# Publish the Helm chart to your Docker repository
echo "Publishing the Helm chart to Docker repository..."
#helm registry login registry-1.docker.io -u gautampachnanda
#helm push spicedb-operator-$chosen_version.tgz oci://registry-1.docker.io/docker

# Clean up
cd ..
rm bundle.yaml

echo "Helm chart for version $chosen_version has been published."