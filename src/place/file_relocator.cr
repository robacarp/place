class Place::FileRelocator
  getter base_directory : String
  getter file_path : String
  getter filename : String
  getter extension : String

  getter destination_directory = ""
  getter final_name = ""
  getter name_slugs = [] of String

  def self.run
    Options.instance.tap do |options|
      new(options.files_to_place.first, options.placement_dir).tap do |relocator|
        relocator.navigate_directory
        relocator.inspect_filename
        relocator.summarize
      end
    end
  end

  def initialize(@file_path, @base_directory)
    @filename, @extension = File.basename(@file_path).split('.', 2)
  end

  def summarize
    summary = <<-TEXT
    Relocator and renamer will:

     - move #{file_path} to #{destination_directory}
     - rename to #{final_name}

    Continue? [Ny] :
    TEXT

    prompt = Interface::Prompt.new(summary)
    answer = prompt.run

    case answer
    when "y", "Y", "yes"
      puts "execute"
    else
      puts "ABORT"
    end
  end
  end

  def navigate_directory
    directory_searcher = DirectoryNavigator.new base_directory
    directory_searcher.full_screen = true
    directory_searcher.run

    if directory_searcher.current_dir.nil?
      STDERR.puts "no directory selected, abort."
      exit 1
    end

    @destination_directory = directory_searcher.current_dir.path

    # Discard the directory prefix of the base placement directory
    @name_slugs = directory_searcher.current_dir.path.split("/").compact.reject(&.blank?)
    dismissable_slug_count = base_directory.split('/').compact.reject(&.blank?).size
    name_slugs.shift dismissable_slug_count
  end

  def inspect_filename
    name_slugs.push filename
    name_editor = NameChooser.new name_slugs, filename, extension
    name_editor.full_screen = true
    @final_name = name_editor.run
  end
end
