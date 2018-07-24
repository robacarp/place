module Place
  class Menu
    SAVE = "\x1b7"#"\x1b[s"
    RESTORE = "\x1b8"#"\x1b[u"
    CLEAR_DOWN = "\x1b[J"
    CLEAR_SCREEN = "\x1b[2J"
    CRLF = "\n\r"

    ENABLE_ALT_BUFFER = "\x1b[?1049h"
    DISABLE_ALT_BUFFER = "\x1b[?1049l"

    getter heading
    getter options
    getter search_chars
    getter search_string
    getter matches
    getter choice : String?

    def puts(thing)
      print thing
      print "#{CRLF}"
    end

    def initialize(@heading : String, @options : Array(String))
      @chosen = false
      @matches = [] of String
      @search_chars = [] of Char
      @search_string = ""
    end

    def choose
      print ENABLE_ALT_BUFFER
      print SAVE
      display
      ask_for_input
      print DISABLE_ALT_BUFFER

      choice
    end

    def clear
      print RESTORE
      print CLEAR_DOWN
    end

    def formatted_options
      multiple_matches = matches.size > 1

      options.map do |o|
        if match? o
          if multiple_matches
            " - #{o.colorize(:black).on(:white)}"
          else
            " - #{o.colorize(:black).on(:green)}"
          end
        else
          " - #{o}"
        end
      end.join CRLF
    end

    def rebuild_search_string
      @search_string = search_chars.map(&.to_s).join("")
    end

    def match?(o : String) : Bool
      return false if search_string.blank?
      Matcher.search(o).for(search_string)

      # if search_string =~ /[A-Z]/
      #   o.starts_with? search_string
      # else
      #   o.downcase.starts_with? search_string.downcase
      # end
    end

    def build_matches
      @matches = options.select { |o| match? o }
    end

    def display
      print RESTORE
      puts heading
      puts formatted_options
      print "Choose: "

      search_chars.each do |c|
        print c
      end
    end

    def ask_for_input
      STDIN.raw do
        loop do
          char = STDIN.read_char

          if char
            search_chars << char
          end

          process_input_char
          rebuild_search_string
          build_matches
          clear
          display

          break if chosen?
          break if search_chars.size > 100
        end
      end
    end

    def process_input_char : Nil
      case search_chars.last
      when .control?
        decode_control_character
      when .alphanumeric?
      when .whitespace?
      else
        puts "unrecognized character: #{search_chars.last.ord}"
      end
    end

    def clear_search
      @search_chars = [] of Char
    end

    def chosen?
      @chosen
    end

    def take_result
      case matches.size
      when .>(1)
      when .==(1)
        @chosen = true
        @choice = matches.first
      when .==(0)
        @chosen = true
        @choice = nil
      end
    end

    def decode_control_character : Nil
      control = search_chars.pop
      case control.ord
      when 1   # ^a
        clear_search
      when 2   # ^b
      when 3   # ^c
        exit 1
      when 5   # ^e
      when 6   # ^f
      when 13  # Enter Key
        take_result
      when 14  # ^n
      when 16  # ^p
      when 23  # ^w
      when 26  # ^z
      when 27  # ESC
        if search_chars.empty?
          @choice = nil
          @chosen = true
        else
          clear_search
        end
      when 91  # arrow?
      when 127 # backspace
        search_chars.pop unless search_chars.empty?
      else
        puts "control character:"
        puts control.ord
        puts
      end
    end

  end
end
