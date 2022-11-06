#!/bin/ruby
require_relative 'i3_common'
require 'json'

if isFocuedWorkspaceOccupied() then
   require_relative 'i3_goto_empty_workspace'
end

