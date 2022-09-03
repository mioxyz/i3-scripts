#!/bin/bash
# Been having the problem that when I reset i3, the workspace names are
# being reset as well, so I'm moving the init logic from ~/.i3/config
# to here instead and then calling this in the config file.
# create /tmp/i3/ directory, if it doesn't exist.
mkdir -p "/tmp/i3"

if [ ! -f "/tmp/i3/workspace_names.txt" ]; then
   echo -e '1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n' > "/tmp/i3/workspace_names.txt"
fi
