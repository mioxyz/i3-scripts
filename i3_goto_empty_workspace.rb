#!/bin/ruby
require 'json'

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

# speed: 377 calls of main function to one second (tested with gnomon), which equates to ~2.6ms [+/-] 0.2ms per call, once ruby std has loaded. This doesn't factor out the 50ms which it takes to load ruby itself.
# loading ruby itself costs about 50ms
# 

occupied = findOccupied( JSON.parse(%x[i3-msg -t get_tree]), [])

if 8 <= occupied.length then
   #puts "THIS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
   %x[i3-msg "exec terminal"]
   %x[ notify-send --expire-time 1200 "all workspaces are occupid."]
   exit true
end

puts "occupied.length: #{occupied.length}"

File.open("/tmp/i3/workspace_names.txt").each do |line|
   name = line.chomp
   if !occupied.include? name then
      puts name
      %x[i3-msg "workspace #{name}"]
      renameWorkspace name
      exit true
   end
end

puts "_FULL_"

exit true
