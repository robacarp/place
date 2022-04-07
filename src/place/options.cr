class Place::Options
  getter placement_dir = ""
  getter files_to_place = [] of String

  def self.instance
    @@instance ||= new
  end

  def parse
    parser.parse
  end

  def guard
    if ! File.exists?(placement_dir) || ! File.info(placement_dir).directory?
      error_and_exit "Must supply placement directory"
    end

    if ! files_to_place.any?
      error_and_exit "Must supply at least one file to place"
    end

    if files_to_place.size > 1
      error_and_exit "Can only tolerate placing one file at a time"
    end
  end

  def error_and_exit(message = "")
    if message.size > 0
      STDERR.puts message
      STDERR.puts
    end

    STDERR.puts parser
    exit 1
  end

  private def parser
    @parser ||= begin
      OptionParser.new do |parser|
        parser.banner = "Usage: #{PROGRAM_NAME} -d <placement dir> <file>"

        parser.on("-d=", "--search-dir=", "Initializes the placement search directory") do |dir|
          @placement_dir = dir
        end

        parser.on("-h", "This is help.") do
          STDERR.puts parser
          exit 1
        end

        parser.unknown_args do |files|
          files.each do |file|
            @files_to_place << file
          end
        end

        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit 1
        end
      end
    end
  end

end
