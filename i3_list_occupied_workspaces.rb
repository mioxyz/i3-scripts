#!/bin/ruby
require 'json'
def i3_list_occupied_workspaces_wrapper(parent, accum)
   if nil == parent then 
      return accum 
   end
   if 'workspace' == parent["type"] and -1 != parent["num"] then
      accum.push parent["name"] # we still need to continue, if workspace contains workspaces
   end
   parent['nodes'].each do |child|
      accum = (child, accum)
   end
   return i3_list_occupied_workspaces_wrapper(nil, accum)
end

def i3_list_occupied_workspaces
   return i3_list_occupied_workspaces_wrapper( JSON.parse %x(i3-msg -t get_tree), []).join(" ")
end

# speed: 377 calls of main function to one second (tested with gnomon), which
# equates to ~2.6ms [+/-] 0.2ms per call, once ruby std has loaded. This
# doesn't factor out the 50ms which it takes to load ruby itself. loading ruby
# itself costs about 50ms

# TODO is it possible to hide the wrapper function? I don't think ruby has something
# comparable to export, or any way to hide stuff

# exit true
