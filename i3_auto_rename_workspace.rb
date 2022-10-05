#!/bin/ruby
require 'json'

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

# extracts all sub-children which is a window (i.e. window key isn't null)
def extractNormalWindows(r)
   # puts "+++extractNormalWindows"
   def f(parent, accum)
      # puts JSON.generate(parent)
      unless parent['window'].nil? then
         accum.push(parent)
      end
      parent['nodes'].each do |child|
         # we can't simply concat the arrays because for some reason
         # we are getting duplicates. Don't understand how this is possible,
         # since the graph structure is a tree.
         accum.concat f(child, accum)
         #dump = f(child, accum)
         #dump.each do |elem|
            #unless elem["id"] ==
         #end
      end
      return accum
   end
   return f(r, [])
end

def getWindowsById(id)
   dump = getNodeById(id)
   return extractNormalWindows(dump)
end




def escapeSed(string)
   accum = ""
   string.each_char do |c|
      if "$.*/[\\]^".include? c then accum.concat "\\" end
      accum.concat c
   end
   return accum
end


def getName(node)
   if node.nil? or "workspace" == node["type"] then return nil end
   # puts JSON.generate(node)
   #sClass = node["window_properties"]["class"]
   sTitle = node["window_properties"]["title"]

   case node["window_properties"]["class"]
      when "Chromium"
         return "Web"
      when "code-oss"
         dump = sTitle.split(' - ')
         return  "Code #{dump[dump.length - 3]}"
      when "firefox"
         return "Web"
      when "jetbrains-studio"
         return "Android"
      when "Spotify"
         return "Music"
      when "thunderbird"
         return "Mail"
      when "keepassxc"
         return "passwd"
   end
end

JSON.parse(%x[i3-msg -t get_workspaces]).each do |workspace|
   # unless workspace['focused'] then next end
   windows = getWindowsById(workspace['id'])

   if nil == windows or windows.empty? then next end

   # puts JSON.generate(workspace)
   # puts workspace['id']
   # puts JSON.generate(windows)

   # count unique windows
   unique_window_exists = false
   unique_window_count = 0
   unique_window = nil
   dump = windows.uniq
   windows.uniq.each do |window|
      #puts "class: #{window["window_properties"]["class"]}"
      unless "Alacritty" == window["window_properties"]["class"] then
         # THIS IS NOW IMPOSSIBLE only count a window as non-unique if it doesn't share a class
         # we do this because if we have thunderbird open and a sub-window
         # (such as an email) then we still want to classify the workspace as
         # "Mail"
         # if unique_window["window_properties"]["class"] == window["window_properties"]["class"]
         unique_window_count = 1 + unique_window_count
         unique_window = window
      # end
   end

   unless 1 == unique_window_count then
      puts "unique_window is not 1: unique_window_count: #{unique_window_count}"
      next
   end
   puts JSON.generate(workspace);
   number = workspace['name'][0]
   puts "number: #{number}"
   newName = "#{number}:{#{number}} #{getName(unique_window)}"

   puts "i3-msg 'rename workspace \"#{workspace['name']}\" to \"#{newName}\"'\""
   %x(i3-msg 'rename workspace "#{workspace['name']}" to "#{newName}"')
   puts "sed -i '#{number}s/.*/#{escapeSed(newName)}/' \"/tmp/i3/workspace_names.txt\""
   %x(sed -i '#{number}s/.*/#{escapeSed(newName)}/' "/tmp/i3/workspace_names.txt")
end
end
