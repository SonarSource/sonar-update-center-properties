#!/bin/bash
set -euo pipefail

: "${CIRRUS_BUILD_ID?}"
: "${UPDATE_CENTER_PROPERTIES_FILE:=update-center-source.properties}"
OUTPUT_DIR="$PWD/target/update-center"
OUTPUT_DIR_ALL_VERSIONS="$PWD/target/update-center-all-versions"
EDITIONS_OUTPUT_DIR="$PWD/target/editions"
EDITIONS_OUTPUT_DIR_ALL_VERSIONS="$PWD/target/editions.allversions"
BINTRAY_REPO=CommercialDistribution
BINTRAY_PACKAGE=editions
SONAR_UPDATE_CENTER_VERSION=1.31.0.1207

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
pushd "${SCRIPT_DIR}/.." >/dev/null

# hint: the edition generation does not solve relative path correctly, have to move to directory before running
echo "Generate metadata into ${OUTPUT_DIR}..."
mvn -DinputFile="${UPDATE_CENTER_PROPERTIES_FILE}" \
  -DoutputDir="${OUTPUT_DIR}" \
  -DeditionsDownloadBaseUrl="https://binaries.sonarsource.com/${BINTRAY_REPO}/${BINTRAY_PACKAGE}" \
  -DeditionsOutputDir="${EDITIONS_OUTPUT_DIR}" \
  -DeditionBuildNumber="${CIRRUS_BUILD_ID}" \
  org.sonarsource.update-center:sonar-update-center-mojo:"${SONAR_UPDATE_CENTER_VERSION}":generate-metadata \
  -e -U -B -V
echo
echo "Generate all metadata versions into ${OUTPUT_DIR_ALL_VERSIONS}..."
mvn -DinputFile="${UPDATE_CENTER_PROPERTIES_FILE}" \
  -DoutputDir="${OUTPUT_DIR_ALL_VERSIONS}" \
  -DincludeArchives=true \
  -DeditionsDownloadBaseUrl="https://binaries.sonarsource.com/${BINTRAY_REPO}/${BINTRAY_PACKAGE}" \
  -DeditionsOutputDir="${EDITIONS_OUTPUT_DIR_ALL_VERSIONS}" \
  -DeditionBuildNumber="${CIRRUS_BUILD_ID}" \
  org.sonarsource.update-center:sonar-update-center-mojo:"${SONAR_UPDATE_CENTER_VERSION}":generate-metadata \
  -e -U -B -V
echo
echo "Generate HTML into ${OUTPUT_DIR}..."
mvn -DinputFile="${UPDATE_CENTER_PROPERTIES_FILE}" \
  -DoutputDir="${OUTPUT_DIR}" \
  org.sonarsource.update-center:sonar-update-center-mojo:"${SONAR_UPDATE_CENTER_VERSION}":generate-html \
  -e -U -B -V
echo
echo "Generate JSON into ${OUTPUT_DIR}..."
mvn -DinputFile="${UPDATE_CENTER_PROPERTIES_FILE}" \
  -DoutputDir="${OUTPUT_DIR}" \
  -DdevMode=false \
  org.sonarsource.update-center:sonar-update-center-mojo:"${SONAR_UPDATE_CENTER_VERSION}":generate-json \
  -e -U -B -V
echo
echo "Generate done"

popd >/dev/null
export OUTPUT_DIR OUTPUT_DIR_ALL_VERSIONS
