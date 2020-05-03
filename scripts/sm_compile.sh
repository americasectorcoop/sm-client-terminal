#!/bin/bash

# MIT License
# 
# Copyright (c) 2020 Alejandro Suárez
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function sm_compile() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    
    directory=$(git rev-parse --show-toplevel)
    # changing to main directory
    cd $directory
    # files edited
    files_edited=$(git status -s | cut -c 4- | grep -P ".sp$|.inc$")
    compiler="$SM_PATH/spcomp64"
    compile_path="$SM_PATH/compiled"
    
    files_compiled=()
    
    function compile_file() {
      local filename=$1
      if [[ ! "${files_compiled[@]}" =~ "${filename}" ]]; then
        sm_message "\ncompiling: ${COLOR_PURPLE}$filename\n"
        path="$SM_PATH/$filename"
        $compiler $path -D $compile_path -v 2 -i
        files_compiled+=($filename)
        sm_line_break
      fi
    }
    
    for file_edited in $files_edited; do
      if [[ $file_edited =~ ^include ]];
      then
        include_file=$(str_replace "include/" "" $file_edited)
        include_file=$(str_replace ".inc" "" $include_file)
        scripts=$(ls | grep -P ".sp$")
        for script in $scripts; do
          contains=$(cat $script | grep "^#include <$include_file>")
          if [ -n "$contains" ]; then
            compile_file $script
          fi
        done
      else
        compile_file $file_edited
      fi
    done
    
    sm_message "compiled:${COLOR_PURPLE} ${#files_compiled[@]}${COLOR_RESTORE} files"
  else
    echo "The current directory is not a folder with git"
  fi
}
