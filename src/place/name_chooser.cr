module Place
  class NameChooser < Interface::Base
    getter selected : Int32
    getter slugs

    def initialize(@slugs : Array(String))
      @selected = 0

      hide_cursor
    end

    def cleanup
      show_cursor
    end

    def display
      puts "Modify the name of the file:"

      display_slugs = slugs.map_with_index do |slug, i|
        if selected == i
          slug.colorize(:black).on(:white)
        else
          slug
        end
      end.join " - "

      puts display_slugs
      puts

      puts "</>     select segment"
      puts "i       insert segment"
      puts "DEL     remove segment"
      puts "^p      move segment up one"
      puts "^n      move segment down one"
    end

    def editing_display
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
      slugs[selected] = SlugEditor.new(slugs, selected).run
      hide_cursor
    end

    def key_enter
      launch_editor
    end

    def key_delete
      slugs.delete_at selected
    end

    def character_key(keystroke)
      case keystroke.data
      when 'i'
        insert_segment
      end
    end

    def insert_segment
      slugs.insert selected, ""
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
  end
end
