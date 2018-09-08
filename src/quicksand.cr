require "http/server"
require "ngrok"
require "./quicksand/*"
require "crouton"

module Quicksand
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end

LOGGER = Quicksand::Logger.new
Quicksand::Logger.promote!(LOGGER)

begin
  c = Quicksand::Config.new

  LOGGER.quiet! if c.quiet
  LOGGER.verbose! if c.verbose

  if c.daemonize
    pipe = Crouton.go do |pipe|
      LOGGER.daemonize!
      Quicksand::App.main(c, pipe)
    end
    force(pipe.gets)
    force
    exit 0
  else
    Quicksand::App.main(c)
    exit 0
  end
rescue e
  print e.message
  puts
  exit 1
end
