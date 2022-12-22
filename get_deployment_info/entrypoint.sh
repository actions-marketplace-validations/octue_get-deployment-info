#!/bin/sh -l

# Get inputs
GCP_PROJECT_NAME=$1
GCP_PROJECT_NUMBER=$2
GCP_REGION=$3
GCP_RESOURCE_AFFIX=$4
GCP_SERVICE_NAME=$5
GCP_ENVIRONMENT=$6

# Get package version.
if [ -f "pyproject.toml" ]; then VERSION=$(poetry version -s); \
elif [ -f "setup.py" ]; then VERSION=$(python setup.py --version);
fi

echo "version=$VERSION" >> $GITHUB_OUTPUT

# Get GCP variables.
echo "gcp_project_name=$GCP_PROJECT_NAME" >> $GITHUB_OUTPUT
echo "gcp_project_number=$GCP_PROJECT_NUMBER" >> $GITHUB_OUTPUT
echo "gcp_region=$GCP_REGION" >> $GITHUB_OUTPUT
echo "gcp_resource_affix=$GCP_RESOURCE_AFFIX" >> $GITHUB_OUTPUT
echo "gcp_service_name=$GCP_SERVICE_NAME" >> $GITHUB_OUTPUT
echo "gcp_environment=$GCP_ENVIRONMENT" >> $GITHUB_OUTPUT

# Get slugified branch name, resource names, and docker image tags.
echo "short_sha=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT

BRANCH_TAG_KEBAB=$(echo ${GITHUB_REF#refs/heads/} | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z)
echo "branch_tag_kebab=$BRANCH_TAG_KEBAB" >> $GITHUB_OUTPUT

BRANCH_TAG_SCREAMING=$(echo $BRANCH_TAG_KEBAB | tr '[:lower:]' '[:upper:]'  | tr - _)
echo "branch_tag_screaming=$BRANCH_TAG_SCREAMING" >> $GITHUB_OUTPUT

if [ "$BRANCH_TAG_KEBAB" = "main" ]; then
  TAG_VERSION=$VERSION
else
  TAG_VERSION="unreleased"
fi

VERSION_SLUG=$(echo $TAG_VERSION | tr . -)
echo "version_slug=$VERSION_SLUG" >> $GITHUB_OUTPUT

IMAGE_VERSION_TAG="$BRANCH_TAG_KEBAB-$TAG_VERSION"
echo "image_version_tag=$IMAGE_VERSION_TAG" >> $GITHUB_OUTPUT

IMAGE_LATEST_TAG="$BRANCH_TAG_KEBAB-latest"
echo "image_latest_tag=$IMAGE_LATEST_TAG" >> $GITHUB_OUTPUT

# Set image artefact addresses.
echo "image_version_artefact=$GCP_REGION-docker.pkg.dev/$GCP_PROJECT_NAME/$GCP_RESOURCE_AFFIX/$GCP_SERVICE_NAME:$IMAGE_VERSION_TAG" >> $GITHUB_OUTPUT
echo "image_latest_artefact=$GCP_REGION-docker.pkg.dev/$GCP_PROJECT_NAME/$GCP_RESOURCE_AFFIX/$GCP_SERVICE_NAME:$IMAGE_LATEST_TAG" >> $GITHUB_OUTPUT