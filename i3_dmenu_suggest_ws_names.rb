#!/bin/ruby
require 'json'

def findFocused(parent)
   if parent["focused"] then return parent end
   parent["nodes"].each do |child|
      maybe = findFocused child
      if maybe then return maybe end
   end
   return nil
end

def escapeSed(string)
   accum = ""
   string.each_char do |c|
      if "$.*/[\\]^".include? c then accum.concat "\\" end
      accum.concat c
   end
   return accum
end

suggestions = []

node = findFocused JSON.parse %x[i3-msg -t get_tree]

unless node.nil? or "workspace" == node["type"]
   puts JSON.generate(node)
   #sClass = node["window_properties"]["class"]
   sTitle = node["window_properties"]["title"]
   includeTitleAndClass = true
   includeName = true

   case node["window_properties"]["class"]
      when "Alacritty"
         # check if we are editing something with kakoune
         if sTitle.match? "Kakoune" then
            suggestions.push("[K]")
            suggestions.push( "[K] #{sTitle.split('-').first.split(' ').first}")
         elsif sTitle.match? "ranger:" then
            suggestions.push( "[R] #{sTitle[7, sTitle.length]}")
         else
            suggestions.push "[T] #{node['name']}"
         end
         suggestions.push "[TERM]"
      when "Chromium"
         suggestions.push "[W]"
         if node["name"].include? "Desmos" then
	         suggestions.push "[W] Desmos"
         else
            suggestions.push "[W] #{node['name']}"
         end
      when "code-oss"
         dump = sTitle.split(' - ')
         if(4 == dump.length) then
            suggestions.push "[C] #{dump[dump.length - 3]}"
         end
         suggestions.push "[C] #{sTitle.split(' - ').first}"
         suggestions.push "[C]"
         includeTitleAndClass = false
         includeName = false
      when "firefox"
         suggestions.push "[W] Firefox"
   end

   if includeName then
      suggestions.push node["name"]
   end

   if includeTitleAndClass then
      if !suggestions.include? node["window_properties"]["title"] then
         suggestions.push node["window_properties"]["title"]
      end

      if !suggestions.include? node["window_properties"]["instance"] then
         suggestions.push node["window_properties"]["instance"]
      end

      if !suggestions.include? node["window_properties"]["class"] then
         suggestions.push node["window_properties"]["class"]
      end

      if node["name"] != node["window_properties"]["title"] then
         suggestions.push "#{node['name']} | #{sTitle}"
      end
   end
end

suggestions.push "clear"

selection = %x[echo -e "#{suggestions.join("\n")}" | dmenu -fn 'Droid Sans Mono-14' -l 12]

JSON.parse(%x[i3-msg -t get_workspaces]).each do |workspace|
   if (not workspace['focused']) next
   number = workspace['name'][0]
   if ["clear", '\n', ''].include? selection.chomp then
      newName = number
   else
      newName = "#{number}:{#{number}} #{selection.chomp}"
   end
   %x[i3-msg 'rename workspace "#{workspace['name']}" to "#{newName}"']
   %x[sed -i '#{number}s/.*/#{escapeSed(newName)}/' "/tmp/i3/workspace_names.txt"]
   exit(true)
end

exit true
