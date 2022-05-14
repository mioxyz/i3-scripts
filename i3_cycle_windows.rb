#!/bin/ruby
require 'json'

def findFocused(parent)
   if parent['focused'] then return parent end
   parent['nodes'].each do |child|
      maybe = findFocused child
      if maybe then return maybe end
   end
   return nil
end

def getActiveWorkspaceId()
   workspaces = JSON.parse %x(i3-msg -t get_workspaces)
   workspaces.each do |ws|
      if ws['focused'] then
         return ws['id']
      end
   end
end

def getActiveWorkspace(parent)
   id = getActiveWorkspaceId()
   if parent['id'] == id then return parent end
   parent['nodes'].each do |child|
      maybe = getActiveWorkspace child
      if maybe then return maybe end
   end
   return nil
end

def accumulateIds(parent)
   ids = [];
   parent['nodes'].each do |child|
      if child['type'] != 'workspace' and child['window'] != nil and child['window_type'] != nil  then
         ids.push(child['id']);
      end
      ids |= accumulateIds(child)
   end
   return ids
end

ws = getActiveWorkspace(JSON.parse %x(i3-msg -t get_tree));
ids = accumulateIds(ws);
focusedWindow = findFocused(ws);
ids.select! { |id| focusedWindow['id'] != id }
previousIds = [];
filename = "/tmp/i3/cycle_window_of_ws_#{ws['id']}.csv";

if File.file?(filename) then
   previousIds = File.read(filename).split(",").map{|elem| elem.to_i };
   ids.reject! { |id| previousIds.include?(id) }
   #ids -= previousIds;
end

if ids.length > 0 then
   %x(i3-msg '[con_id="#{ids[0]}"] focus')
   previousIds.push(ids[0]);
   handle = File.new(filename, "w");
   handle.write(previousIds.join(","));
   handle.close();
else
   %x(i3-msg '[con_id="#{previousIds[0]}"] focus')
   handle = File.new(filename, "w");
   handle.write(previousIds[0].to_s);
   handle.close();
end

exit 0;
