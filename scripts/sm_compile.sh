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
    args=$@
    directory=$(git rev-parse --show-toplevel)
    # changing to main directory
    cd $directory
    # files edited
    local files_edited=$(git status -s | grep -v "^\sD" | cut -c 4- | grep -P ".sp$|.inc$")

    if [[ "${args[@]}" =~ "--all" ]]; then
      files_edited=$(find . -type f -name "*sp" | cut -c 3-)
    fi

    local compiler="$SM_PATH/spcomp"
    local plugin_type=$(sm_project_type)
    
    local include_path=$directory/include
    local compile_path=$directory/compiled
    
    if [[ "${plugin_type}" == "full" ]]; then
      include_path=$directory/addons/sourcemod/scripting/include
      compile_path=$directory/addons/sourcemod/scripting/compiled
    elif [[ "${plugin_type}" != "simple" ]]; then
      sm_error "plugin type('$plugin_type') it's not valid"
    fi
    
    if [ -d $include_path ]; then
      cp -R $include_path $SM_PATH/
    fi

    mkdir -p $compile_path
    
    files_compiled_success=()
    files_compiled=()
    
    function compile_file() {
      local filename=$1
      if [[ ! "${files_compiled[@]}" =~ "${filename}" ]]; then
        path="$directory/$filename"
        local output=$($compiler $path -D $compile_path -v 2 -;)
        if [[ "${output}" =~ "error" ]]; then
          printf "\n${COLOR_RED}Error${COLOR_RESTORE} at ${COLOR_PURPLE}$filename${COLOR_RESTORE}\n\n$output\n\n";
        else
          files_compiled_success+=($filename)
        fi
        files_compiled+=($filename)
      fi
    }
    
    for file_edited in $files_edited; do
      if [[ $file_edited =~ "include/" ]];
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
    
    sm_message "${COLOR_GREEN}compiled:${COLOR_PURPLE} ${#files_compiled_success[@]}${COLOR_RESTORE} files"
  else
    echo "The current directory is not a folder with git"
  fi
}
