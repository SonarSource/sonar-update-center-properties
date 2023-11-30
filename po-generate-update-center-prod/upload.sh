#!/bin/bash
set -euo pipefail

: "${TRANSFER_DIR?}"

S3_PATH=sonarqube/update/

echo "Upload from $TRANSFER_DIR to s3://$S3_BUCKET/$S3_PATH..."
aws s3 sync "$@" --delete "$TRANSFER_DIR" "s3://$S3_BUCKET/$S3_PATH"
rm -rf "$TRANSFER_DIR"
echo "Upload done"
