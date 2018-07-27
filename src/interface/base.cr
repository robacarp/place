module Interface
  abstract class Base
    record Keystroke, type : Symbol, value : Symbol, data : Char

    SAVE = "\x1b7"
    RESTORE = "\x1b8"
    CLEAR_DOWN = "\x1b[J"
    CLEAR_SCREEN = "\x1b[2J"

    SHOW_CURSOR = "\x1b[?25h"
    HIDE_CURSOR = "\x1b[?25l"

    BUFFER_SIZE = 6

    getter read_buffer = Bytes.new BUFFER_SIZE
    private property finished = false

    def run
      print SAVE

      loop do
        clear
        before_display
        display
        wait_for_input
        break if finished
      end

      clear
      cleanup
      return_value
    end

    abstract def display
    def before_display; end
    def cleanup; end
    def return_value; end

    def clear
      print RESTORE
      print CLEAR_DOWN
    end

    def character_key(keystroke); end

    {% begin %}
    {%
     special_keys = [
       :backspace,
       :ctrl_c,
       :ctrl_n,
       :ctrl_p,
       :delete,
       :enter,
       :up_arrow,
       :down_arrow,
       :left_arrow,
       :right_arrow,
       :esc
     ]
    %}

      def function_key(keystroke)
        case keystroke.value
        {% for key_name in special_keys %}
        when {{ key_name }} then key_{{ key_name.id }}
        {% end %}
        else
          puts "unknown function key: #{keystroke}"
        end
      end

      {% for key_name in special_keys %}
        def key_{{ key_name.id }}; end
      {% end %}
    {% end %}

    def key_ctrl_c
      cleanup
      puts ""
      exit 1
    end

    def key_pressed(keystroke : Keystroke)
      case keystroke.type
      when :function
        function_key keystroke
      else
        character_key keystroke
      end
    end

    def wait_for_input
      STDIN.raw do
        @read_buffer = Bytes.new BUFFER_SIZE
        count = STDIN.read @read_buffer

        # puts "read #{count} bytes at once: #{@read_buffer} #{@read_buffer.map{|c| c.chr}.join("").lstrip('\e').rstrip('\u{0}')}"

        keystroke = nil

        if count == 0
          return
        elsif count == 1
          keystroke = process_input_char
        else
          keystroke = decode_function_character
        end

        return unless keystroke
        key_pressed keystroke
      end
    end

    def process_input_char : Keystroke
      first_char = read_buffer.first.chr

      case first_char
      when .control?
        decode_control_character
      when .alphanumeric?
        Keystroke.new type: :alphanumeric, value: :letter, data: first_char
      when .whitespace?
        Keystroke.new type: :whitespace, value: :unknown, data: first_char
      else
        puts "unrecognized character: #{first_char} - #{read_buffer.first}"
        Keystroke.new type: :unknown, value: :unknown, data: first_char
      end
    end

    def decode_control_character : Keystroke
      key = case read_buffer.first
      when 1 then :ctrl_a
      when 2 then :ctrl_b
      when 3 then :ctrl_c
      when 5 then :ctrl_e
      when 6 then :ctrl_f
      when 12 then :ctrl_l
      when 13 then :enter
      when 14 then :ctrl_n
      when 16 then :ctrl_p
      when 23 then :ctrl_w
      when 26 then :ctrl_z
      when 27 then :esc
      when 127 then :backspace
      else
        puts "unknown control character: #{puts read_buffer.first}"
        :unknown_control
      end

      Keystroke.new type: :function, value: key, data: read_buffer.first.chr
    end

    def decode_function_character : Keystroke
      key = FunctionKeys.decode_bytes read_buffer
      Keystroke.new type: :function, value: key, data: '\0'
    end

    def show_cursor
      print SHOW_CURSOR
    end

    def hide_cursor
      print HIDE_CURSOR
    end

    def finished?
      finished
    end
  end
end
