require "./ext/*"

require "colorize"
require "option_parser"

require "./interface"
require "./place/**"

placement_dir = "/Users/robert/Box Sync/Files"
files_to_place = [] of String

Place::Options.instance.tap do |options|
  options.parse!
  options.guard!
end

Place::FileRelocator.run
