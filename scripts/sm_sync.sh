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

function sm_sync() {
  PORT=$SSH_PORT
  HOST=$SSH_HOST
  
  USER=$1
  REMOTE_PATH=$2
  
  addons_path_source="$DEBUG_LOCAL_PATH/addons"
  addons_path_target="$REMOTE_PATH/addons"
  
  cfg_path_source="$DEBUG_LOCAL_PATH/cfg"
  cfg_path_target="$REMOTE_PATH/cfg"
  
  lftp -u $USER "sftp://$HOST:$PORT" -e "
    lcd $addons_path_source
    mirror --reverse --delete --verbose $addons_path_source $addons_path_target
    lcd $cfg_path_source
    mirror --reverse --delete --verbose $cfg_path_source $cfg_path_target
    bye
  "
  
  sm_message "sync succesfully:\n{$COLOR_GREEN}$DEBUG_LOCAL_PATH${COLOR_PURPLE} => ${COLOR_GREEN}$REMOTE_PATH"
}

function sm_debug() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    sm_message "updating compiled files to the server"
    cd $(git rev-parse --show-toplevel)
    local compile_path="$(pwd)/compiled"
    cd $compile_path
    cp -R * $DEBUG_LOCAL_PATH/addons/sourcemod/plugins
  else
    sm_message "the current directory is not a folder with git"
  fi
}

function sm_release() {
  sm_sync $PRODUCTION_REMOTE_USER $PRODUCTION_REMOVE_PATH
}

function sm_deploy() {
  sm_sync $DEBUG_REMOTE_USER $DEBUG_REMOTE_PATH
}
