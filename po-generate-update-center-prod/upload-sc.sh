#!/bin/bash
set -euo pipefail

: "${OUTPUT_DIR?}" "${UPDATE_CENTER_PROPERTIES_FILE?}" "${S3_BUCKET?}"
S3_PATH=sonarqube/update

TRANSFER_DIR=$(mktemp -d -p "$PWD" -t tranfer.XXXXXXXX)
trap 'rm -rf "$TRANSFER_DIR"' EXIT

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
pushd "${SCRIPT_DIR}/.." >/dev/null
eval "$(grep scanners "$UPDATE_CENTER_PROPERTIES_FILE")"
popd >/dev/null

# shellcheck disable=SC2154
echo "Prepare $scanners files for transfer into $TRANSFER_DIR"
paths=()
IFS=","
for scanner in $scanners; do
  cp "$OUTPUT_DIR/json/$scanner.json" "$TRANSFER_DIR/"
  paths+=("/$S3_PATH/$scanner.json")
done
unset IFS
echo "Prepare done"

echo "Upload from $TRANSFER_DIR to s3://$S3_BUCKET/$S3_PATH/..."
aws s3 sync "$@" "$TRANSFER_DIR" "s3://$S3_BUCKET/$S3_PATH/"
echo "Upload done"
rm -rf "$TRANSFER_DIR"
trap - EXIT

DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[].{DomainName:DomainName}[?starts_with(DomainName,'$S3_BUCKET')]}[?not_null(origin)].id" --output text)
echo "Create CloudFront invalidation for distribution $DISTRIBUTION_ID"
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "${paths[@]}"
