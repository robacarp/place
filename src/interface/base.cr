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

        break if finished?
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
         :ctrl_a,
         :ctrl_b,
         :ctrl_c,
         :ctrl_d,
         :ctrl_e,
         :ctrl_f,
         :ctrl_g,
         :ctrl_h,
         :ctrl_i,
         :ctrl_j,
         :ctrl_k,
         :ctrl_l,
         :enter,
         :ctrl_n,
         :ctrl_o,
         :ctrl_p,
         :ctrl_q,
         :ctrl_r,
         :ctrl_s,
         :ctrl_t,
         :ctrl_u,
         :ctrl_v,
         :ctrl_w,
         :ctrl_x,
         :ctrl_y,
         :ctrl_z,
         :backspace,
         :delete,
         :up_arrow,
         :down_arrow,
         :left_arrow,
         :right_arrow,
         :escape
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
        # puts
        # puts "read: #{@read_buffer.inspect}"
        # puts
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
      when 4 then :ctrl_d
      when 5 then :ctrl_e
      when 6 then :ctrl_f
      when 7 then :ctrl_g
      when 8 then :ctrl_h
      when 9 then :ctrl_i
      when 10 then :ctrl_j
      when 11 then :ctrl_k
      when 12 then :ctrl_l
      when 13 then :enter
      when 14 then :ctrl_n
      when 15 then :ctrl_o
      when 16 then :ctrl_p
      when 17 then :ctrl_q
      when 18 then :ctrl_r
      when 19 then :ctrl_s
      when 20 then :ctrl_t
      when 21 then :ctrl_u
      when 22 then :ctrl_v
      when 23 then :ctrl_w
      when 24 then :ctrl_x
      when 25 then :ctrl_y
      when 26 then :ctrl_z
      when 27 then :escape
      when 127 then :backspace
      else
        puts "unknown control character: #{read_buffer.first}"
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

    def finish!
      self.finished = true
    end

  end
end
