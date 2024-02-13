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

def accumulateWindows(parent)
   windows = [];
   parent['nodes'].each do |child|
      if child['type'] != 'workspace' and child['window'] != nil and child['window_type'] != nil then
         windows.push(child);
      end
      windows |= accumulateWindows(child)
   end
   return windows
end

ws = getActiveWorkspace(JSON.parse %x(i3-msg -t get_tree));
windows = accumulateWindows(ws);
min_x = windows.min_by { |w| w['rect']['x'] }['rect']['x']
max_x = windows.max_by { |w| w['rect']['x'] }['rect']['x']
min_y = windows.min_by { |w| w['rect']['y'] }['rect']['y']
max_y = windows.max_by { |w| w['rect']['y'] }['rect']['y']

# this builds the sr array which is used in the i3_sensible_resize.rb script. Bind this script to your resize key (e.g. Mod+r), 
# execute the complementary script on h,j,k,l key presses in i3.
File.open("/tmp/i3/sensible_resize.csv", "w") do |handle|
   handle.write([
      windows.select { |w| w['rect']['x'] == min_x }.map { |w| w['id'] }.join(','), # left
      windows.select { |w| w['rect']['x'] == max_x }.map { |w| w['id'] }.join(','), # right
      windows.select { |w| w['rect']['y'] == min_y }.map { |w| w['id'] }.join(','), # up
      windows.select { |w| w['rect']['y'] == max_y }.map { |w| w['id'] }.join(','), # down
   ].join("\n"))
end

exit 0
