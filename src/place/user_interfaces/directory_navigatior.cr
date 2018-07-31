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

    def return_value
      @current_dir.path
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
      puts "Select a destination folder for the file."
      puts
      puts "Searching in #{@current_dir.path} :"
      puts formatted_options
      puts
      puts "------------------"

      if cursor_active?
        puts "ENTER		Navigate to directory".colorize.bold
      else
        if matches.size == 1
          puts "ENTER		Navigate to directory".colorize.bold
        else
          puts "ENTER		Navigate to directory".colorize.dim
        end
      end

      if cursor_active? || matches.size == 1
        puts "^d		Place file in selected directory"
      else
        puts "^d		Place file in this directory"
      end

      puts
      puts "ESC		Clear filter"
      puts "^p		Navigate up (..)"
      puts "^n		Create Directory"
      puts "^o		Open Directory in Finder"
      puts "↑ / ↓		Manually select Directory"
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

    def key_ctrl_d
      return if ! cursor_active? && matches.size >= 1

      if cursor_active?
        switch_directory options[cursor_position]
      elsif matches.size == 1
        switch_directory matches.first
      end

      self.finished = true
    end
  end
end
