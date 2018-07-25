module Place
  class Menu
    SAVE = "\x1b7"#"\x1b[s"
    RESTORE = "\x1b8"#"\x1b[u"
    CLEAR_DOWN = "\x1b[J"
    CLEAR_SCREEN = "\x1b[2J"

    BUFFER_SIZE = 6

    getter heading
    getter options
    getter search_chars
    getter search_string
    getter input_buffer
    getter matches
    getter choice : String?

    def initialize(@heading : String, @options : Array(String))
      @chosen = false
      @matches = [] of String
      @search_chars = [] of Char
      @search_string = ""

      @input_buffer = Bytes.new BUFFER_SIZE
    end

    def choose
      print SAVE
      display
      ask_for_input
      clear
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
      State.with_tty_raw do
        loop do
          @input_buffer = Bytes.new BUFFER_SIZE
          count = STDIN.read @input_buffer

          # puts "read #{count} bytes at once: #{@input_buffer} #{@input_buffer.map{|c| c.chr}.join("").lstrip('\e').rstrip('\u{0}')}"

          if count == 0
            next
          elsif count == 1
            process_input_char
            rebuild_search_string
            build_matches
          else
            decode_function_character
          end

          break if chosen?
          break if search_chars.size > 100

          clear
          display
        end
      end
    end

    def process_input_char : Nil
      first_char = input_buffer.first.chr

      case first_char
      when .control?
        decode_control_character
      when .alphanumeric?
        search_chars << first_char
      when .whitespace?
      else
        puts "unrecognized character: #{first_char} - #{input_buffer.first}"
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
      case input_buffer.first
      when 1   # ^a
        clear_search
      when 2   # ^b
      when 3   # ^c
        exit 1
      when 5   # ^e
      when 6   # ^f
      when 12  # ^l
        clear
        display
      when 13  # Enter Key
        take_result
      when 14  # ^n
      when 16  # ^p
      when 23  # ^w
      when 26  # ^z
      when 27  # ESC
        esc_key
      when 127 # backspace
        search_chars.pop unless search_chars.empty?
      when 224
        puts
        puts "arrow?"
        puts
      else
        puts "control character:"
        puts input_buffer.first
        puts
      end
    end

    def esc_key
      puts "ESC key"
      return
      if search_chars.empty?
        @choice = nil
        @chosen = true
      else
        clear_search
      end
    end

    def decode_function_character
      key = FunctionKeys.decode_bytes input_buffer
      if key == :arrow_up
      end
    end

  end
end
