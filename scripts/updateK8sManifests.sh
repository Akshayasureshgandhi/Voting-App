#!/usr/bin/env bash
set -e

APP_NAME="$1"          
IMAGE_REPO="$2"        
IMAGE_TAG="$3"         

MANIFEST="k8s-specifications/${APP_NAME}-deployment.yaml"

echo "Running updateK8sManifests.sh"
echo "APP_NAME   = $APP_NAME"
echo "IMAGE_REPO = $IMAGE_REPO"
echo "IMAGE_TAG  = $IMAGE_TAG"
echo "MANIFEST   = $MANIFEST"

# --- NEW: guard against empty repo ---
if [ -z "$IMAGE_REPO" ]; then
  echo "ERROR: IMAGE_REPO is empty. Check pipeline variables." >&2
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: Manifest file '$MANIFEST' not found." >&2
  exit 1
fi

echo "----- BEFORE -----"
grep -n "image" "$MANIFEST" || true

echo "Updating image in $MANIFEST to ${IMAGE_REPO}:${IMAGE_TAG}"

# Replace only the 'image:' line, keeping normal indentation
sed -i -E "s|(^[[:space:]]-?[[:space:]]*image[[:space:]]:[[:space:]]).|\1${IMAGE_REPO}:${IMAGE_TAG}|" "$MANIFEST"

echo "----- AFTER -----"
grep -n "image" "$MANIFEST" || true

git config user.email "devops@akshayagandhi017.com" || true
git config user.name  "Azure DevOps Pipeline" || true

if git diff --quiet "$MANIFEST"; then
  echo "No changes detected in $MANIFEST. Nothing to commit."
  exit 0
fi

git add "$MANIFEST"
git commit -m "Update ${APP_NAME} image to ${IMAGE_REPO}:${IMAGE_TAG}"

BRANCH_NAME="${BUILD_SOURCEBRANCHNAME:-}"
if [ -z "$BRANCH_NAME" ] && [ -n "${BUILD_SOURCEBRANCH:-}" ]; then
  BRANCH_NAME="${BUILD_SOURCEBRANCH#refs/heads/}"
fi

git push origin HEAD:"$BRANCH_NAME"

echo "Kubernetes manifest updated and pushed successfully."