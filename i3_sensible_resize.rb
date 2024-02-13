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

def accumulateWindows(parent, excludeId)
   windows = [];
   parent['nodes'].each do |child|
      if child['type'] != 'workspace' and child['window'] != nil and child['window_type'] != nil and child['id'] != excludeId then
         windows.push(child);
      end
      windows |= accumulateWindows(child, excludeId)
   end
   return windows
end

ws = getActiveWorkspace(JSON.parse %x(i3-msg -t get_tree));
focusedWindow = findFocused(ws);
windows = accumulateWindows(ws, focusedWindow['id']);

module Orientation
   LEFTMOST = 0
   RIGHTMOST = 1
   UPMOST = 2
   DOWNMOST = 3
end

sr = File.read("/tmp/i3/sensible_resize.csv").split("\n").map do |line| 
   line.split(',').map { |x| x.to_i }
end

if ARGV[0] == 'left' then
   %x(i3-msg resize #{sr[Orientation::LEFTMOST].include?(focusedWindow['id']) ? 'shrink' : 'grow'} width 10 px or 10 ppt)
elsif ARGV[0] == 'right' then
   %x(i3-msg resize #{sr[Orientation::RIGHTMOST].include?(focusedWindow['id']) ? 'shrink' : 'grow'} width 10 px or 10 ppt)
elsif ARGV[0] == 'up' then
   %x(i3-msg resize #{sr[Orientation::UPMOST  ].include?(focusedWindow['id']) ? 'shrink' : 'grow'} height 10 px or 10 ppt)
elsif ARGV[0] == 'down' then
   %x(i3-msg resize #{sr[Orientation::DOWNMOST].include?(focusedWindow['id']) ? 'shrink' : 'grow'} height 10 px or 10 ppt)
end

exit 0
