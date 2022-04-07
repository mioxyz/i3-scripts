#!/bin/ruby

# TODO parse pactl list sinks into Array of Class Sink, which wraps data.

def i3_get_sink_in_state(state)
   #puts "+++i3_get_sink_in_state(#{state})";
   dump=%x[pactl list sinks].split("\n")
   sinkNumber = ""
   parseState = false
   dump.each do |line|
      if line.include? "Sink #" then
         # sink number can be double digits
         # puts "»#{line[6, line.length]}«"
         sinkNumber = line[6, line.length]
         parseState = true
      else
         #puts "got into else case..."
         if parseState then
            parseState = false;
            if line.include? "State: #{state}" then
               # puts sinkNumber
               return sinkNumber
            end
         end
      end
   end
   #puts "Error: no active sink found."
   return -1
end

def i3_get_active_sink()
   maybe = i3_get_sink_in_state("RUNNING");
   if -1 == maybe then
      return i3_get_sink_in_state("SUSPENDED");
   end
   return maybe
end

def i3_get_active_sink_all() # Array
   dump=%x[pactl list sinks].split("\n")
   sinkNumbers = []
   parseState = false
   dump.each do |line|
      if line.include? "Sink #" then
         # sink number can be double digits
         #puts "»#{line[6, line.length]}«"
         sinkNumbers.push line[6, line.length]
         parseState = true
      else
         #puts "got into else case..."
         if parseState then
            parseState = false;
            if line.include? "State: RUNNING" then
               return sinkNumbers
            end
         end
      end
   end
   # if we find no active sinks, choose the first suspended 
   # sink (sinks are suspended if no active audio media is playing).
   return []
end
