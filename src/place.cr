require "./global"

require "colorize"
require "option_parser"

require "./place/*"

placement_dir = "/Users/robert/Box Sync/Files"
files_to_place = [] of String

option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [arguments]"

  parser.on("-d", "--search-dir", "Initializes the placement search directory") do |dir|
    placement_dir = dir
  end

  parser.on("-h", "This is help.") do
    puts parser
    exit 1
  end

  parser.unknown_args do |files|
    files.each do |file|
      files_to_place << file
    end
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit 1
  end
end

option_parser.parse!

if ! File.exists?(placement_dir) || ! File.info(placement_dir).directory?
  puts "Must supply placement directory"
  puts
  puts option_parser
  exit 1
end

if ! files_to_place.any?
  puts "Must supply at least one file to place"
  puts
  puts option_parser
  exit 1
end


with_alternate_buffer do
  Place::NameChooser.new(["one","two","three"]).run
  searcher = Place::Searcher.search placement_dir
  unless searcher.current_dir
    puts "no directory selected, abort."
    exit 1
  end
end

files_to_place.first

