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

File.open("/tmp/i3/sensible_resize.csv", "w") do |handle|
   handle.write([ 
      windows.select { |w| w['rect']['x'] == min_x }.map { |w| w['id'] }.join(','), # left
      windows.select { |w| w['rect']['x'] == max_x }.map { |w| w['id'] }.join(','), # right
      windows.select { |w| w['rect']['y'] == min_y }.map { |w| w['id'] }.join(','), # up
      windows.select { |w| w['rect']['y'] == max_y }.map { |w| w['id'] }.join(','), # down
   ].join("\n"))
end

split_content = File.read("/tmp/i3/sensible_resize.csv").split(",")
#puts("split_content: #{split_content}")
# for w in windows do
#       if focusedWindow['rect']['x'] > w['rect']['x'] then
#          isLeftmost = false
#       end
#       if focusedWindow['rect']['x'] < w['rect']['x'] then
#          isRightmost = false
#       end
#    end
#    if isLeftmost then
#       %x(i3-msg resize shrink width 10 px or 10 ppt)
#    elsif isRightmost then
#       %x(i3-msg resize grow width 10 px or 10 ppt)
#    end
# elsif ARGV[0] == 'right' then
#    isLeftmost = true
#    isRightmost = true
#    for w in windows do
#       if focusedWindow['rect']['x'] > w['rect']['x'] then
#          isLeftmost = false
#       end
#       if focusedWindow['rect']['x'] < w['rect']['x'] then
#          isRightmost = false
#       end
#    end
#    if isLeftmost then
#       %x(i3-msg resize grow width 10 px or 10 ppt)
#    elsif isRightmost then
#       %x(i3-msg resize shrink width 10 px or 10 ppt)
#    end
# end

# # ids.select! { |id| focusedWindow['id'] != id }
# # previousIds = [];
# filename = "/tmp/i3/sensible_resize.csv";

# # if File.file?(filename) then
#    previousIds = File.read(filename).split(",").map{|elem| elem.to_i };
#    ids.reject! { |id| previousIds.include?(id) }
#    #ids -= previousIds;
# end

# if ids.length > 0 then
#    %x(i3-msg '[con_id="#{ids[0]}"] focus')
#    previousIds.push(ids[0]);
#    handle = File.new(filename, "w");
#    handle.write(previousIds.join(","));
#    handle.close();
# else
#    %x(i3-msg '[con_id="#{previousIds[0]}"] focus')
#    handle = File.new(filename, "w");
#    handle.write(previousIds[0].to_s);
#    handle.close();
# end

exit 0