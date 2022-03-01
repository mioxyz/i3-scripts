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

puts JSON.generate findFocused JSON.parse %x[i3-msg -t get_tree]
exit true
