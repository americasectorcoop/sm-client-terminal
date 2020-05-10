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
  . $file
done

CURRENT_GAME=$(sm_detect_game)

if [ $CURRENT_GAME != "undefined" ]; then
  export $(cat $SM_PATH/environments/$CURRENT_GAME.env | xargs)
fi

sm_message "\n${COLOR_GREEN}SOURCEMOD CLIENT TOOLS"

type=$1
args=$(shift;echo $@)

if [[ "${type}" =~ "compile" ]]; then
  sm_compile $args
  elif [[ "${type}" =~ "debug" ]]; then
  sm_debug $args
  elif [[ "${type}" =~ "deploy" ]]; then
  sm_deploy $args
  elif [[ "${type}" =~ "release" ]]; then
  sm_release $args
  elif [[ "{$type}" =~ "game" ]]; then
  sm_message "plugin game: ${COLOR_PURPLE}$CURRENT_GAME"
  elif [[ "{$type}" =~ "methodmapize" ]]; then
  $SM_PATH/scripts/methodmapize.py $args
else
  sm_message "  ${COLOR_BLUE}compile ${COLOR_YELLOW}=>${COLOR_RESTORE} compile edited/new files"
  sm_message "  ${COLOR_BLUE}debug ${COLOR_YELLOW}=>${COLOR_RESTORE} release to local server"
  sm_message "  ${COLOR_BLUE}deploy ${COLOR_YELLOW}=>${COLOR_RESTORE} release to development server"
  sm_message "  ${COLOR_BLUE}release ${COLOR_YELLOW}=>${COLOR_RESTORE} release to production server"
  sm_message "  ${COLOR_BLUE}game ${COLOR_YELLOW}=>${COLOR_RESTORE} return game detected"
  sm_message "  ${COLOR_BLUE}methodmapize ${COLOR_YELLOW}=>${COLOR_RESTORE} the script will do some regular expression replacements and save the new file in the same directory with .m appended to the file name."
fi

sm_line_break
