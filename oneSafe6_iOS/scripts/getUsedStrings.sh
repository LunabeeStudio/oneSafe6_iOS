#!/bin/sh

# Proprocessor macros cleaning.
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CODE_DIR="${CURRENT_DIR}/../oneSafe"

clear

echo "┎-----------------------------------------------------------------------------------------┒"
echo "|                          👉 Checking oneSafe used strings 👈                            |"
echo "|-----------------------------------------------------------------------------------------|"
echo "|                                                                                         |"
echo "| 1️⃣  Checking strings...                                                                  |"
find "${CODE_DIR}" -type f -name '*.swift' -exec "${CURRENT_DIR}/getUsedStrings.swift" {} +
pbcopy < "${CURRENT_DIR}/result"
rm -f "${CURRENT_DIR}/result"
echo "|                                                                                         |"
echo "|-----------------------------------------------------------------------------------------|"
echo "|                   🎉 Strings keys successfully copied to clipboard 🎉                   |"
echo "┖-----------------------------------------------------------------------------------------┚"
