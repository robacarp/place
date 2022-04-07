module Place
  class DirectoryNavigator < Keimeno::Menu
    RULE = "------------------------------------"

    getter current_dir
    property file_to_place : String? = nil

    def self.search(dir)
      new(dir).tap {|s| s.search}
    end

    def initialize(@base_dir : String)
      @current_dir = Dir.new @base_dir
      @heading = ""

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
      puts RULE

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
        selected = "selected".colorize.bold
        puts "^d		Place file in #{selected} directory"
      else
        puts "^d		Place file in this directory"
      end

      puts "ESC		Clear filter"

      if file_to_place
        puts RULE
        puts "^q		Quick Look File"
        puts "^o		Open File"
        puts RULE
      end

      puts "^p		Navigate up (..)"
      puts "^n		Create Directory"
      puts "↑ / ↓		Manually select Directory"
      puts RULE
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
      new_directory_name = Keimeno::Prompt.new(
        "Create new directory in #{@current_dir.path}:"
      ).run

      return if new_directory_name.size == 0
      return if new_directory_name == "."
      return if new_directory_name == ".."

      Dir.mkdir( File.join @current_dir.path, new_directory_name )

      switch_directory new_directory_name
    end

    def key_ctrl_o
      if file = @file_to_place
        Process.run "/usr/bin/open", [file]
      end
    end

    def key_ctrl_d
      return if ! cursor_active? && matches.size >= 1

      if cursor_active?
        switch_directory options[cursor_position]
      elsif matches.size == 1
        switch_directory matches.first.text
      end

      self.finished = true
    end

    def key_ctrl_q
      if file = @file_to_place
        args = ["-p"]
        args << file

        spawn do
          Process.run "qlmanage", args
        end

        repaint
      end
    end
  end
end
