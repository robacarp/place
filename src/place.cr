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

if files_to_place.size > 1
  puts "Can only tolerate placing one file at a time"
  puts
  puts option_parser
  exit 1
end

file_to_place = File.join(Dir.current, files_to_place.first)
filename = File.basename files_to_place.first
filename, extension = filename.split('.')
searcher = Place::Searcher.new placement_dir
name_chooser = nil
new_name = ""

with_alternate_buffer do
  searcher.search

  unless searcher.current_dir
    puts "no directory selected, abort."
    exit 1
  end
end

puts "Final directory: #{searcher.current_dir.path}"

with_alternate_buffer do
  name_parts = searcher.current_dir.path.split('/').compact.reject(&.blank?)

  dismissable_slugs = placement_dir.split('/').size - 1
  name_parts.shift dismissable_slugs
  name_parts.push filename

  new_name = Place::NameChooser.new(name_parts, extension).run
end

puts "Final name: #{new_name}"

