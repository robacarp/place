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
      puts "^p		Navigate up (..)"
      puts "^n		Create Directory"
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
      new_directory = Interface::Prompt.new(
        "Create new directory in #{@current_dir.path}:"
      ).run
    end
  end
end
