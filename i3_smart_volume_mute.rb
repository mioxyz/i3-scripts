#!/bin/ruby
require_relative 'i3_get_active_sink.rb'
sink=i3_get_active_sink()
puts "sink: #{sink}"
system "pactl set-sink-mute #{sink} toggle && $refresh_i3status"
