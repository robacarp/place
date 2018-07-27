module Place
  class DirectoryNavigator < Interface::Menu
    getter current_dir

    def self.search(dir)
      new(dir).tap {|s| s.search}
    end

    def initialize(@base_dir : String)
      @current_dir = Dir.new @base_dir
      @heading = ""
      @options = [] of String
      @matches = [] of String

      repopulate_options
    end

    def repopulate_options : Array(String)
      @options = @current_dir.children.select do |path|
        File.info(File.join @current_dir.path, path).directory?
      end.sort
    end

    def key_enter
      super

      # If a subdirectory was chosen
      if finished? && (choice_ = choice)
        switch_directory choice_
        self.finished = false
        self.cursor_position = -1
      end
    end

    def switch_directory(new_path : String)
      @current_dir = Dir.new(
          File.real_path(
            File.join @current_dir.path, new_path
          )
        )
      repopulate_options
      set_input_text ""
    end

    def display
      puts "Searching in #{@current_dir.path} :"
      puts formatted_options
      puts "------------------"
      puts "ESC		Clear filter"

      if cursor_active?
        puts "ENTER		Navigate to directory".colorize.bold
      else
        case matches.size
        when 0
          puts "ENTER		Select current directory"
        when 1
          puts "ENTER		Navigate to directory".colorize.bold
        else
          puts "ENTER		Navigate to directory".colorize.dim
        end
      end

      puts "^p		Navigate up (..)"
      puts "^n		Create Directory"
      puts "^o		Open Directory in Finder"
      puts "------------------"
      print "Filter: "
      print input_text
    end

    def key_ctrl_p
      if @current_dir.path.size > @base_dir.size
        switch_directory ".."
      end
    end

    def key_ctrl_n
      clear
      new_directory_name = Interface::Prompt.new(
        "Create new directory in #{@current_dir.path}:"
      ).run

      return if new_directory_name.size == 0
      return if new_directory_name == "."
      return if new_directory_name == ".."

      Dir.mkdir( File.join @current_dir.path, new_directory_name )

      switch_directory new_directory_name
    end

    def key_ctrl_o
      `/usr/bin/open '#{@current_dir.path}'`
    end
  end
end
