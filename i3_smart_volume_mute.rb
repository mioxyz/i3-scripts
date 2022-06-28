#!/bin/ruby
require 'json'

# smart sink muter

def mute_sink( sinkId, muteState )
   `pactl set-sink-mute #{sinkId} #{muteState}`
end

sinks = JSON.parse(`~/code/projects/i3-scripts/bin/json_sinks`);

running_sinks = sinks.select{ |sink| sink["state"] == "RUNNING" }

if 0 == running_sinks.length() then
   running_sinks.push(sinks.last)
end


running_unmuted_sinks = running_sinks.select{ |sink| !sink["mute"] }

# if we have unmuted running sinks, then mute these
if 0 == running_unmuted_sinks.length() then
   running_sinks.each{ |sink| mute_sink(sink["id"], 0) }
else
   running_unmuted_sinks.each{ |sink| mute_sink(sink["id"], 1) }
end

# notice that there is no such think as the "active" sink
# there are just running sinks, i.e. you can have multiple
# sinks which are running in parallel and have different
# applications sending it audio data, e.g. have youtube play
# on sink #4 and have mpv play on sink #3
# One approach might be to look up all currently RUNNING
# sinks and see if they are muted. If you press the mute button
# and there are un-muted sinks which are RUNNING, all
# RUNNING sinks will be muted.
# If all RUNNING sinks are muted, on the other hand, then
# all sinks are un-muted. This gives us a consistent, predictable
# behaviour of the mute button, suitable for a laptop.

