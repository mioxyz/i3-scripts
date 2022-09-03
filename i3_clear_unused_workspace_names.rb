#!/bin/ruby
require 'json'
require 'ostruct'
# INCOMPLETE CODE
# gave up on this because i3-msg cannot rename workspaces which 
# do not exist.

def getWorkspaces
   def f(parent)
      workspaces = []
      if "workspace" == parent.type and "__i3_scratch" != parent.name then
         workspaces.push parent
      end
      parent.nodes.each do |child|
         workspaces.concat f child
      end
      return workspaces
   end
   return f JSON.parse(%x(i3-msg -t get_tree), object_class: OpenStruct )
end

occupiedWorkspaces = []

getWorkspaces().each do |workspace|
   if workspace.nodes then
      if 0 == workspace.nodes.length then
         puts "workspace »#{workspace.name}« seems to be empty..."
      else
         puts "workspace »#{workspace.name}« seems to have »#{workspace.nodes.length} nodes.«"
         occupiedWorkspaces.push workspace.num
      end
   end
end

workspaceNames = File.read("/tmp/i3/workspace_names.txt").split "\n"

#puts outp.split("\n").map{ |line| puts "»#{line}«" }
#File.write("/tmp/i3/workspace_names.txt", "0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n")
num = 0
workspaceNames.each do |name|
   num += 1;
   if !occupiedWorkspaces.include? num then
      puts "#{num} is unoccupied."
      if name.length > 1 then
         puts "#{num} is unoccupied... and still has a custom name: »#{name}«"
         %x[i3-msg 'rename workspace #{num} to "#{num}"']
         puts "i3-msg 'rename workspace \"#{name}\" to \"#{num}\"']"
      end
   end
end









