#!/bin/ruby
require 'json'
#require 'ostruct'

workspaceNumber = ARGV[0]

# determine if the focused container is a workspace
def isFocusedContainerWorkspace()
   def findFocused(parent)
      if parent["focused"] then return parent end
      parent["nodes"].each do |child|
         maybe = findFocused child
         if maybe then return maybe end
      end
      return nil
   end
   container = findFocused JSON.parse %x(i3-msg -t get_tree)
   if !container then
      return false
   end
   return "workspace" == container["type"]
end

workspaceName = %x(sed "#{workspaceNumber}q;d" "/tmp/i3/workspace_names.txt").chomp

if (!workspaceName) or "123456789".include? workspaceName then
   %x(i3-msg "workspace \"#{workspaceNumber}\"")
   exit true
end

%x(i3-msg "workspace \"#{workspaceName}\"")

if isFocusedContainerWorkspace() then
   %x(i3-msg 'rename workspace \"#{workspaceName}\" to #{workspaceNumber}')
   # remove the workspace name from the list of workspaceNames
   %x[sed -i '#{workspaceNumber}s/.*/#{workspaceNumber}/' "/tmp/i3/workspace_names.txt"]
end
