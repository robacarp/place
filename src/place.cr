require "colorize"
require "option_parser"
require "file_utils"

require "keimeno"
require "./place/**"

files_to_place = [] of String

Place::Options.instance.tap do |options|
  options.parse!
  options.guard!
end

Place::FileRelocator.run
