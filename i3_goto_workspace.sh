#!/bin/bash
# goto a specific named workspace the names should be located in /tmp/i3/workspace_names.txt
# this will take the  n'th line in the file which corresponds to the n'th workspace.
# If the line is missing, then we assume that no special name has been assigned.
workspace_name=$(sed "$1q;d" "/tmp/i3/workspace_names.txt")
if [ -z "$workspace_name" ]; then
   i3-msg "workspace \"$1\""
else
   i3-msg "workspace \"$workspace_name\""
fi
