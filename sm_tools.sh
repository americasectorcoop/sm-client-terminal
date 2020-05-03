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

SM_PATH=~/.sourcemod

for file in $SM_PATH/scripts/*.sh; do
  source $file
done


function sm() {
  CURRENT_GAME=$(sm_detect_game)

  export $(cat $SM_PATH/environments/$CURRENT_GAME.env | xargs)

  sm_message "${COLOR_GREEN}SOURCEMOD CLIENT TOOLS\n"
    
  type=$1
  
  if [[ "${type}" =~ "compile" ]]; then
    sm_compile
    elif [[ "${type}" =~ "debug" ]]; then
    sm_debug
    elif [[ "${type}" =~ "deploy" ]]; then
    sm_deploy
    elif [[ "${type}" =~ "release" ]]; then
    sm_release
    elif [[ "{$type}" =~ "game" ]]; then 
    sm_message "plugin game: ${COLOR_PURPLE}$CURRENT_GAME"
  fi

  sm_line_break
}
