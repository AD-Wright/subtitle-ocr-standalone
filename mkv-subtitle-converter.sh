#!/bin/bash

# Script to extract subtitles from MKV and convert to SRT
# Version 1.0

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for mkvmerge
    if ! command -v mkvmerge &> /dev/null; then
        missing_deps+=("mkvmerge (from mkvtoolnix package)")
    fi
    
    # Check for tesseract
    if ! command -v tesseract &> /dev/null; then
        missing_deps+=("tesseract-ocr")
    fi
    
    # Check for subtile-ocr
    if ! command -v subtile-ocr &> /dev/null; then
        missing_deps+=("subtile-ocr")
    fi
    
    # If any dependencies are missing, alert the user
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: The following required tools are missing:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo -e "\nPlease install these dependencies to use this tool."
        exit 1
    fi
}

# Check if an input file was provided
if [ $# -ne 1 ]; then
    echo "========================================"
    echo "MKV Subtitle Converter"
    echo "========================================"
    echo "Usage: $0 <input.mkv>"
    echo ""
    echo "This tool extracts subtitle tracks from MKV files"
    echo "and converts them to SRT format using OCR."
    exit 1
fi

# Check dependencies before proceeding
check_dependencies

INPUT_FILE=$1

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

# Check if the input file is an MKV file
if [[ "$INPUT_FILE" != *.mkv ]]; then
    echo "Error: The input file must be an MKV file."
    exit 1
fi

# Get the base filename without path and extension
FILENAME=$(basename "$INPUT_FILE")
BASE_NAME="${FILENAME%.*}"

# Create a temporary directory with a unique name based on the filename
TEMP_DIR="/tmp/subtitle_extract_${BASE_NAME}_$(date +%s)"
mkdir -p "$TEMP_DIR"

# Clear screen and show header
clear
echo "========================================"
echo "MKV Subtitle Converter"
echo "========================================"
echo "Processing: $FILENAME"
echo "========================================"
echo ""

# List all subtitle tracks in the MKV file
echo "Available subtitle tracks:"
echo "------------------------"
mkvmerge -i "$INPUT_FILE" | grep "subtitles" | nl -v 0
echo ""

# Ask the user which subtitle track to extract
read -p "Enter the number of the subtitle track to extract: " TRACK_NUM

# Validate that the input is a number
if ! [[ "$TRACK_NUM" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid track number. Please enter a valid number."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo ""
echo "========================================"
echo "Select OCR language (default: eng)"
echo "Common options: eng (English), fra (French), deu (German), chi_sim (Simplified Chinese)"
echo "For more languages, see Tesseract documentation"
echo "========================================"
read -p "Enter language code [eng]: " LANG_CODE

# Set default language if none provided
LANG_CODE=${LANG_CODE:-eng}

# Extract the subtitle track to the temporary directory
echo ""
echo "Extracting subtitle track $TRACK_NUM from '$INPUT_FILE'..."
mkvextract tracks "$INPUT_FILE" "$TRACK_NUM:$TEMP_DIR/$BASE_NAME.idx"

# Check if extraction was successful
if [ ! -f "$TEMP_DIR/$BASE_NAME.idx" ]; then
    echo "Error: Subtitle extraction failed."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Convert to SRT using subtile-ocr
echo "Converting subtitle to SRT format using OCR (language: $LANG_CODE)..."
echo "This may take a few minutes depending on the subtitle length."
echo ""

subtile-ocr -l "$LANG_CODE" -o "$TEMP_DIR/$BASE_NAME.srt" "$TEMP_DIR/$BASE_NAME.idx"

# Check if conversion was successful
if [ -f "$TEMP_DIR/$BASE_NAME.srt" ]; then
    # Copy the final SRT file to the current directory
    cp "$TEMP_DIR/$BASE_NAME.srt" "./$BASE_NAME.srt"
    echo ""
    echo "========================================"
    echo "Conversion successful!"
    echo "Subtitle saved as: ./$BASE_NAME.srt"
    echo "========================================"
else
    echo "Error: Conversion to SRT failed."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo ""
echo "Process completed. Your subtitle file is ready."
