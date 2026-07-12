#!/bin/bash
#
# Copyright (C) 2019-2026 crDroid Android Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
#

# $1 = TARGET_DEVICE
# $2 = PRODUCT_OUT
# $3 = FILE_NAME

DEVICE="$1"
PRODUCT_OUT="$2"
FILENAME="$3"

# Detect build variant
if [[ "$FILENAME" == *"vanilla"* ]]; then
    BUILD_VARIANT="vanilla"
else
    BUILD_VARIANT="gapps"
fi

# Set OTA json location
if [[ "$BUILD_VARIANT" == "vanilla" ]]; then
    existingOTAjson="./vendor/OTA/builds/vanilla/${DEVICE}.json"
    DOWNLOAD_URL="https://sourceforge.net/projects/ghosuto/files/${DEVICE}/vanilla/${FILENAME}/download"
else
    existingOTAjson="./vendor/OTA/builds/${DEVICE}.json"
    DOWNLOAD_URL="https://sourceforge.net/projects/ghosuto/files/${DEVICE}/${FILENAME}/download"
fi

output="${PRODUCT_OUT}/${DEVICE}.json"

# Cleanup old file
if [ -f "$output" ]; then
    rm "$output"
fi

echo "Generating JSON file data for OTA support..."

# Helper function to extract field from JSON
extract_field() {
    grep "\"$1\":" "$existingOTAjson" \
        | sed -n "s/.*\"$1\": *\"\([^\"]*\)\".*/\1/p" \
        | xargs
}

# Load existing OTA metadata if present
if [ -f "$existingOTAjson" ]; then
    MAINTAINER=$(extract_field "maintainer")
    OEM=$(extract_field "oem")
    DEVICE_NAME=$(extract_field "device")
    BUILDTYPE=$(extract_field "buildtype")
    FORUM=$(extract_field "forum")
    GAPPS=$(extract_field "gapps")
    FIRMWARE=$(extract_field "firmware")
    MODEM=$(extract_field "modem")
    BOOTLOADER=$(extract_field "bootloader")
    RECOVERY=$(extract_field "recovery")
    PAYPAL=$(extract_field "paypal")
    TELEGRAM=$(extract_field "telegram")
    DT=$(extract_field "dt")
    COMMON_DT=$(extract_field "common-dt")
    KERNEL=$(extract_field "kernel")
fi

# Extract version from filename
VERSION=$(echo "$FILENAME" | cut -d'-' -f5 | sed 's/v//')
V_MAX=$(echo "$VERSION" | cut -d'.' -f1)
V_MIN=$(echo "$VERSION" | cut -d'.' -f2)
VERSION="$V_MAX.$V_MIN"

# Build information
BUILDPROP="$PRODUCT_OUT/system/build.prop"
TIMESTAMP=$(grep "ro.system.build.date.utc" "$BUILDPROP" | cut -d'=' -f2)
OS_PATCH_LEVEL=$(grep -m1 "^ro.build.version.security_patch=" "$BUILDPROP" | cut -d'=' -f2)
OS_SDK_LEVEL=$(grep -m1 "^ro.build.version.sdk=" "$BUILDPROP" | cut -d'=' -f2)

MD5=$(md5sum "$PRODUCT_OUT/$FILENAME" | cut -d' ' -f1)
SHA256=$(sha256sum "$PRODUCT_OUT/$FILENAME" | cut -d' ' -f1)
SIZE=$(stat -c "%s" "$PRODUCT_OUT/$FILENAME")

# Generate JSON
cat <<EOF >"$output"
{
  "response": [
    {
      "maintainer": "${MAINTAINER:-}",
      "oem": "${OEM:-}",
      "device": "${DEVICE_NAME:-$DEVICE}",
      "filename": "$FILENAME",
      "download": "$DOWNLOAD_URL",
      "timestamp": $TIMESTAMP,
      "md5": "$MD5",
      "sha256": "$SHA256",
      "size": $SIZE,
      "version": "$VERSION",
      "os_patch_level": "${OS_PATCH_LEVEL:-}",
      "os_sdk_level": ${OS_SDK_LEVEL:-0},
      "buildtype": "${BUILDTYPE:-}",
      "forum": "${FORUM:-}",
      "gapps": "${GAPPS:-}",
      "firmware": "${FIRMWARE:-}",
      "modem": "${MODEM:-}",
      "bootloader": "${BOOTLOADER:-}",
      "recovery": "${RECOVERY:-}",
      "paypal": "${PAYPAL:-}",
      "telegram": "${TELEGRAM:-}",
      "dt": "${DT:-}",
      "common-dt": "${COMMON_DT:-}",
      "kernel": "${KERNEL:-}"
    }
  ]
}
EOF

if [ ! -f "$existingOTAjson" ]; then
    echo "There is no official support for this device yet"
fi

echo "JSON file generation completed"
