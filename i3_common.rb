#!/bin/ruby
require 'json'
#require 'ostruct'

$tree = JSON.parse %x(i3-msg -t get_tree)

def getNodeById(id)
   def f(parent, id)
      if parent['id'] == id then
         return parent
      end
      parent['nodes'].each do |child|
         maybe = f(child, id)
         unless nil == maybe then return maybe end
      end
      return nil
   end
   return f($tree, id)
end

def isFocuedWorkspaceOccupied
   JSON.parse(%x(i3-msg -t get_workspaces)).each do |workspace|
      #if workspace["nodes"] then
         if workspace["visible"] and workspace["focused"] then
            ws = getNodeById(workspace["id"]);
            if ws == nil then
               puts "couldn't find ws with that id.";
               exit true;
            end
            if 0 == ws["nodes"].length then
               puts "active & focused ws seems to be empty."
               return false
            else
               puts "active & focused ws seems to be occupied."
               return true
            end
         end
      #end
   end
end


























