#!/usr/bin/env bash

FILE_TYPE=$1
PATTERN=$2

if [ "$FILE_TYPE" = "cc" ]; then
  files=$( find . \( -name "*.h" -o -name "*.cc" -o -name "*.c" -o -name "*.cpp" -o -name "*.hpp" \) )
elif [ "$FILE_TYPE" = "cmake" ]; then
  files=$( find . \( -name "CMakeLists.txt" \) )
elif [ "$FILE_TYPE" = "py" ]; then
  files=$( find . \( -name "*.py" \) )
else
  echo "Unknown file category: $FILE_TYPE!"
  exit
fi

grep $PATTERN $files
