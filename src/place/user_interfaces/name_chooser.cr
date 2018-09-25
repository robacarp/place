module Place
  class NameChooser < Keimeno::Base
    getter selected : Int32
    getter slugs, destination_directory, filename, extension
    getter suggested_name_slugs

    def initialize(@suggested_name_slugs : Array(String), @destination_directory : String, @filename : String, @extension : String)
      @slugs = [] of String
      @slugs = @suggested_name_slugs.dup
      @selected = slugs.size - 1
      hide_cursor
    end

    def cleanup
      show_cursor
    end

    def display_slugs
      slugs.map_with_index do |slug, i|
        if selected == i
          slug.colorize(:black).on(:white)
        else
          slug
        end
      end.join " - "
    end

    def display_directory_listing
      children = Dir.children(destination_directory).sort

      <<-TEXT
      Contains #{children.size} item#{children.size > 1 ? 's' : ""}:

       - #{children.first(5).each.join("\n - ")}
      TEXT
    end

    def display
      puts "Based off of the chosen directory, this name is being suggested."
      puts "If you wish, you may edit the filename or press ^d to finish and move the file."
      puts

      puts "File will be moved to: #{destination_directory}"
      puts
      puts display_directory_listing
      puts
      puts "------------------"
      puts

      print display_slugs
      print "."
      puts extension
      puts

      puts "------------------"
      puts "^d		Finish editing and move file".colorize.bold
      puts

      puts "←/→,h/l		select segment"
      puts "ENTER		change (edit) segment"
      puts
      puts "^r		revert entire name to original"
      puts "^s		revert to initial suggestion"
      puts
      puts "DEL		remove segment"
      puts "i/a		insert/append segment"
      puts "^p		move segment up one"
      puts "^n		move segment down one"
      puts "------------------"
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

    def launch_editor
      clear
      show_cursor

      maintain_saved_cursor do
        name_editor = NameEditor.new(slugs, selected, filename)
        slugs[selected] = name_editor.run
      end

      hide_cursor
      clear
    end

    def launch_quicklook
      Process.new(
        command : String,
        args = nil
      )
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
      when 'o'
        open_directory
      when 'h'
        key_left_arrow
      when 'l'
        key_right_arrow
      end
    end

    def key_enter
      launch_editor
    end

    def open_directory
      Process.run "/usr/bin/open", [destination_directory]
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

    def key_ctrl_d
      self.finished = true
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

    def key_ctrl_r
      @slugs = [ filename ]
      constrain_selection
    end

    def key_ctrl_s
      @slugs = @suggested_name_slugs.dup
      constrain_selection
    end

    def return_value
      "#{slugs.join(" - ")}.#{extension}"
    end
  end
end
