require "colorize"

require "./place/*"

module Place
  class Searcher
    def initialize(@base_dir : String)
      @current_dir = Dir.new @base_dir
    end

    def search_in
      search
      puts "Finished at #{@current_dir.path}"
    end

    private def search
      descendants = @current_dir.children
        .select do |path|
          File.info( File.join @current_dir.path, path ).directory?
        end

      choice = Menu.new("Searching in #{@current_dir.path}...", descendants.sort).choose

      if choice
        @current_dir = Dir.new(File.join @current_dir.path, choice)
        search
      end
    end
  end
end

require "option_parser"

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

# if ! files_to_place.any?
#   puts "Must supply at least one file to place"
#   puts
#   puts option_parser
#   exit 1
# end
# 
# puts "Will try to place these files:"
# puts files_to_place.map { |name| "- #{name}"}.join "\n"

searcher = Place::Searcher.new placement_dir
searcher.search_in
