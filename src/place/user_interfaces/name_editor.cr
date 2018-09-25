module Place
  class NameEditor < Keimeno::Base
    include Keimeno::TextInput

    getter slugs, selected, file

    def initialize(@slugs : Array(String), @selected : Int32, @file : String)
      set_input_text slugs[selected]
    end

    def display
      puts "Modify a segment of the filename:"

      display_slugs = slugs.map_with_index do |slug, i|
        text = slug
        text = "<>" if text == ""

        if selected == i
          text.colorize(:black).on(:green)
        else
          text
        end
      end.join " - "

      puts display_slugs
      puts

      print "Segment: "
    end

    def return_value
      input_text
    end

    # save the edit
    def key_enter
      if input_text.size > 0
        finish!
      end
    end

    # discard the edit
    def key_escape
      set_input_text slugs[selected]
      finish!
    end
  end
end
