#!/bin/ruby
require_relative 'i3_get_active_sink.rb'
currentDate=%x[date +"%s%N"].to_i
%x[mkdir -p /tmp/i3; touch /tmp/i3/volumeChangeDebounceTimestamp]
handle = File.new("/tmp/i3/volumeChangeDebounceTimestamp", "r")
previousDate = ""
if handle
   previousDate = handle.sysread(handle.size()).to_i
else
   %x[mkdir -p /tmp/i3]
   %x[/tmp/i3/volumeChangeDebounceTimestamp]
   previousDate = 0
end
handle.close
# debounce, if too close to last trigger, exit immediately without writing.
if 250500500 > (currentDate - previousDate) then
   exit 0
end
# for some reason opening the file in FILE::RDWRT doens't work.
handle = File.new("/tmp/i3/volumeChangeDebounceTimestamp", "w")
handle.write currentDate
handle.close
factor = 1
if (currentDate - previousDate) < 750500500 then
   factor = 2
end
activeSink = i3_get_active_sink()
system "pactl set-sink-mute #{activeSink} 0"
volume = %x[pactl get-sink-volume #{activeSink}].split('/')[1].to_i
if "decr" == ARGV[0].chomp then
   case volume
      when 21..30; factor *= -2
      when  0..20; factor *= -1
      else;        factor *= -5
   end
   #puts "decr volume factor: #{factor}"
   %x[pactl set-sink-volume #{activeSink} #{factor}%]
else
   case volume
      when 86..100; factor *= 5
      when 21..85;  factor *= 2
      when  0..20;  factor *= 1
      else;         factor *= 0
   end
   %x[pactl set-sink-volume #{activeSink} +#{factor}%]
end
