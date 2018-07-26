module Place
  class Menu < Interface::Base
    include Interface::TextInput

    getter heading
    getter options
    getter matches
    getter choice : String?

    def initialize(@heading : String, @options : Array(String))
      @matches = [] of String
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

    def match?(o : String) : Bool
      return false if input_text.blank?
      Matcher.search(o).for(input_text)
    end

    def build_matches
      @matches = options.select { |o| match? o }
    end

    def before_display
      build_matches
    end

    def display
      print RESTORE
      puts heading
      puts formatted_options
      print "Choose: "

      print input_text
    end

    def return_value
      if matches.size == 1
        matches.first
      else
        nil
      end
    end

    def key_enter
      case matches.size
      when .>(1)
      when .==(1)
        self.finished = true
        @choice = matches.first
      when .==(0)
        self.finished = true
        @choice = nil
      end
    end

    def key_esc
      if input_text.empty?
        @choice = nil
        self.finished = true
      else
        set_input_text ""
      end
    end
  end
end
