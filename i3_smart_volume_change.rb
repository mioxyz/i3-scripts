#!/bin/ruby
require "json"
sinks = JSON.parse(`~/code/projects/i3-scripts/bin/json_sinks`)
running_sinks = sinks.select{ |sink| sink["state"] == "RUNNING" }

# if no running_sinks are there, we choose the default sink.
if 0 == running_sinks.length() then
   running_sinks.push(sinks.last)
end

running_sinks.each{ |sink|
   system "pactl set-sink-mute #{sink['id']} 0"
   volume = %x[pactl get-sink-volume #{sink['id']}].split('/')[1].to_i
   if "decr" == ARGV[0].chomp then
      if 5 < volume then
          %x(pactl set-sink-volume #{sink['id']} -5%)
      else
          %x(pactl set-sink-volume #{sink['id']} 0%)
      end
   else
      if 120 > volume then
         %x(pactl set-sink-volume #{sink['id']} +5%)
      else
         %x(pactl set-sink-volume #{sink['id']} 125%)
      end
   end
}

