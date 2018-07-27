module Place
  class NameChooser < Interface::Base
    getter selected : Int32
    getter slugs
    getter extension

    def initialize(@slugs : Array(String), @extension : String)
      @selected = slugs.size - 1
      hide_cursor
    end

    def cleanup
      show_cursor
    end

    def display
      puts "Modify the name of the file (#{selected}):"

      display_slugs = slugs.map_with_index do |slug, i|
        if selected == i
          slug.colorize(:black).on(:white)
        else
          slug
        end
      end.join " - "

      print display_slugs
      print " . "
      print extension
      puts

      puts "←/→     select segment"
      puts "e       edit segment"
      puts "i/a     insert/append segment"
      puts "DEL     remove segment"
      puts "^p      move segment up one"
      puts "^n      move segment down one"
    end

    def constrain_selection
      if selected >= slugs.size
        @selected = slugs.size - 1
      end

      if selected < 0
        @selected = 0
      end
    end

    def key_right_arrow
      case selected
      when .< 0
        @selected = 0
      else
        @selected += 1
        @selected = 0 if @selected >= slugs.size
      end
    end

    def key_left_arrow
      case selected
      when .< 0
        @selected = slugs.size - 1
      else
        @selected -= 1
        @selected = slugs.size - 1 if @selected < 0
      end
    end

    def key_down_arrow
      key_right_arrow
    end

    def key_up_arrow
      key_left_arrow
    end

    def clear
      super
    end

    def launch_editor
      clear
      show_cursor
      slugs[selected] = NameEditor.new(slugs, selected).run
      hide_cursor
    end

    def key_delete
      return if slugs.empty?
      slugs.delete_at selected
      constrain_selection
    end

    def character_key(keystroke)
      case keystroke.data
      when 'i'
        insert_segment
      when 'a'
        append_segment
      when 'e'
        launch_editor
      end
    end

    def insert_segment
      slugs.insert selected, ""
      launch_editor
      constrain_selection
    end

    def append_segment
      slugs.insert(selected + 1, "")
      @selected += 1
      launch_editor
    end

    def key_ctrl_n
      return if selected >= slugs.size - 1

      slug = slugs.delete_at selected
      @selected += 1
      slugs.insert selected, slug
    end

    def key_ctrl_p
      return if selected == 0
      slug = slugs.delete_at selected
      @selected -= 1
      slugs.insert selected, slug
    end

    def key_enter
      self.finished = true
    end

    def return_value
      "#{slugs.join(" - ")}.#{extension}"
    end
  end
end
