#!/bin/ruby
#require_relative 'i3_get_active_sink.rb'
#puts "testing i3_get_active_sink...";
#puts "test 1. i3_get_active_sink_all: ";
#puts i3_get_active_sink_all();
#puts "test 2. i3_get_active_sink";
#puts i3_get_active_sink();
#puts "...test end.";

require 'json'

sinks = JSON.parse(`./bin/json_sinks`);

#puts "output: #{output}";

sinks.each do |sink|
    puts sink['state'];
end

def mute_sinks( sinkId, muteState )
   output = `pactl set-sink-mute #{sinkId} #{muteState}`

   puts "output: »#{output}«";
end

mute_sinks( 5, 5);
