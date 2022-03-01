#!/bin/ruby
# wrapper functions related to i3 window manager belong here.

def notify(message, expire_time = 2000, urgency = "normal")
   %x(notify-send '#{message}' --urgency=#{urgency} --expire-time #{expire_time})
end
