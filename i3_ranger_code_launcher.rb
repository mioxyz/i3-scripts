#!/bin/ruby
require 'json'

def gotoEmptyWorkspace
   def renameWorkspace name
      number = name[0]
      newName = "#{number}:{#{number}} [TERM]"
      %x[i3-msg 'rename workspace "#{name}" to "#{newName}"']
      %x[sed -i '#{number}s/.*/#{newName}/' "/tmp/i3/workspace_names.txt"]
   end

   def findOccupied(parent, accum)
      if nil == parent then
         return accum
      end
      if 'workspace' == parent["type"] and -1 != parent["num"] then
         accum.push parent["name"]
      end
      parent['nodes'].each do |child|
         accum = findOccupied(child, accum)
      end
      return findOccupied(nil, accum)
   end

   occupied = findOccupied( JSON.parse(%x[i3-msg -t get_tree]), [])

   if 8 <= occupied.length then
      %x[i3-msg "exec terminal"]
      %x[ notify-send --expire-time 1200 "all workspaces are occupid."]
      exit true
   end

   #puts "occupied.length: #{occupied.length}"

   File.open("/tmp/i3/workspace_names.txt").each do |line|
      name = line.chomp
      if !occupied.include? name then
         #puts name
         %x[i3-msg "workspace #{name}"]
         renameWorkspace name
         return;
      end
   end
end

def moveToUrgentWorkspace
   def findUrgent(parent)
      if parent['urgent'] and ('workspace' == parent['type']) then
         return parent
      end
      parent['nodes'].each do |child|
         maybe = findUrgent child
         if maybe then return maybe end
      end
      return nil
   end
   
   tries = 10
   while 0 < tries
      maybe = findUrgent JSON.parse %x(i3-msg -t get_tree)
      if maybe then
         %x(i3-msg "workspace \"#{maybe['name']}\"")
         exit true;
      end
      tries -= 1
      sleep 0.1
      puts "...waiting #{10-tries}/10"
   end
   
   puts "no urgent workspace found"
   sleep 0.3   
end

# will contain chars if code instance is running
# this isn't fool-proof. It takes a few seconds for
# code to close or for whatever is behind fuser
# to update and recognize that code is no longer running.
dump = %x(fuser /usr/lib/code/node_modules.asar) 

if 0 == dump.length then
   # if no code insance exists...
   gotoEmptyWorkspace()
end

%x(code #{ARGV[0]})

# we wait after we launch code instance (doesn't make sense as else block)
if 0 != dump.length then
   moveToUrgentWorkspace()
end
