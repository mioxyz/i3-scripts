#!/bin/ruby
require 'json'

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
end

puts "no urgent workspace found"
sleep 0.3
