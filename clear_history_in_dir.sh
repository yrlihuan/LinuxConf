#!/bin/bash

# ./clear_history_in_dir.sh some_dir num_of_files_to_keep
DIR_TO_CLEAR=$1
FILES_TO_KEEP=$2

for f in `ls -rt $DIR_TO_CLEAR | head -n -$2`
do
  rm $DIR_TO_CLEAR/$f
done
