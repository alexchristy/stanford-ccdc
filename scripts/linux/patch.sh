#!/usr/bin/sh

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--diff)
      DIFF_FOLDER="$2"
      shift
      shift
      ;;
    -n|--new)
      NEW_FOLDER="$2"
      shift
      shift
      ;;
    -t|--target)
      TARGET="$2"
      shift
      shift
      ;;
    -h|--help)
      echo "Usage: patch.sh [-t target ansible directory] [-d diffs folder] [-n new files folder] [-h help]"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Patch all existing files
TARGET_FILES=$(find $TARGET -type f)
for DIFF in $(find ${DIFF_FOLDER} -type f | sed 's/^.*diff\//g' | cut -b -5); do
  # find the file we're supposed to be patching
  FILE=$(echo $TARGET_FILES | tr ' ' '\n' | grep $DIFF)
  patch "$FILE" < "${DIFF}.diff"
done

# Manifest has format:
# FILE_NAME DESTINATION

# Move all new files to their proper directories
TARGET_DIRECTORIES=$(find $TARGET -type d)
for NEW_FILE_PATH in $(find ${NEW_FOLDER} -type f | grep -v manifest); do
  # retrieve the file name
  NEW_FILE=$(echo $NEW_FILE_PATH | sed 's/^.*\//g')
  # retrieve its path relative to the ansible root directory
  STUB_DIR=$(grep ${NEW_FOLDER}/manifest $NEW_FILE | awk '{print $2}')
  # retrieve its path relative to the actual target directory
  TARGET_DIR=$(echo $TARGET_DIRECTORIES | tr ' ' '\n' | grep ${STUB_DIR})
  # actually move it to the correct location
  mv $NEW_FILE_PATH $TARGET_DIR
done
