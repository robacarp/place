require "./place/state"

CRLF = "\n\r"

def puts(thing) : Nil
  if Place::State.tty_raw?
    STDOUT.print thing
    STDOUT.print CRLF
    STDOUT.flush
  else
    STDOUT.puts thing
  end
end

def with_alternate_buffer(&block)
  enable_alt_buffer = "\x1b[?1049h"
  disable_alt_buffer = "\x1b[?1049l"

  print enable_alt_buffer
  yield
  print disable_alt_buffer
end
