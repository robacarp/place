module Place
  class SlugEditor < Interface::Base
    include Interface::TextInput

    getter slugs
    getter selected

    def initialize(@slugs : Array(String), @selected : Int32)
      set_input_text slugs[selected]
    end

    def display
      puts "Modify the name of the file:"

      display_slugs = slugs.map_with_index do |slug, i|
        if selected == i
          slug.colorize(:black).on(:green)
        else
          slug
        end
      end.join " - "

      puts display_slugs
      puts

      print "#{input_text}"
    end

    def return_value
      input_text
    end

    def clear
      super
    end

    # save the edit
    def key_enter
      if input_text.size > 0
        self.finished = true
      end
    end

    # discard the edit
    def key_escape
      set_input_text slugs[selected]
      self.finished = true
    end
  end
end
