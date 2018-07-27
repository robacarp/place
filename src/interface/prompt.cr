module Interface
  class Prompt < Base
    include Interface::TextInput

    getter question

    def initialize(@question : String)
    end

    def display
      print "#{question} #{input_text}"
    end

    def key_enter
      self.finished = true
    end

    def return_value
      input_text
    end

    def character_key(keystroke) : Nil
      case keystroke.data
      when .alphanumeric?
        super
      when ' '
        super
      when '.'
        super
      end
    end
  end
end
