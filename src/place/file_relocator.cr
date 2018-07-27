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
    puts "Would move #{file_path} to #{destination_directory}"
    puts "and rename to #{final_name}"
  end

  def navigate_directory
    directory_searcher = DirectoryNavigator.new base_directory

    with_alternate_buffer do
      directory_searcher.run
    end

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
    name_editor = NameChooser.new name_slugs, extension

    with_alternate_buffer do
      @final_name = name_editor.run
    end
  end
end
