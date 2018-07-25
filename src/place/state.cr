module Place
  class State
    def self.instance
      @@state ||= new
    end

    property tty_raw = false

    def self.tty_raw?
      instance.tty_raw
    end

    def self.with_tty_raw(&block)
      instance.tty_raw = true
      STDIN.raw do
        yield
      end
      instance.tty_raw = false
    end
  end
end
