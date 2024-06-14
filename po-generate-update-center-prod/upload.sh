#!/bin/bash
set -euo pipefail

: "${TRANSFER_DIR?}"
: "${S3_BUCKET?}"

S3_PATH=sonarqube/update

echo "Upload from $TRANSFER_DIR to s3://$S3_BUCKET/$S3_PATH/..."
aws s3 sync "$@" --delete "$TRANSFER_DIR" "s3://$S3_BUCKET/$S3_PATH/"
rm -rf "$TRANSFER_DIR"
echo "Upload done"

DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[].{DomainName:DomainName}[?starts_with(DomainName,'$S3_BUCKET')]}[?not_null(origin)].id" --output text)
echo "Create CloudFront invalidation for distribution $DISTRIBUTION_ID"
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/$S3_PATH/*" "/$S3_PATH/plugins/*"
