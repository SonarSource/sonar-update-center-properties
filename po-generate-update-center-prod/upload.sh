#!/bin/bash
set -euo pipefail

: "${TRANSFER_DIR?}"
: "${S3_BUCKET?}"

S3_PATH=sonarqube/update

echo "Upload from $TRANSFER_DIR to s3://$S3_BUCKET/$S3_PATH/..."
aws s3 sync "$@" --delete "$TRANSFER_DIR" "s3://$S3_BUCKET/$S3_PATH/"
rm -rf "$TRANSFER_DIR"
echo "Upload done"

DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[0].DomainName}[?starts_with(origin,'$S3_BUCKET')].id" --output text)
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/$S3_PATH/*" "/$S3_PATH/plugins/*"
