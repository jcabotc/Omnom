require "omnom/config"

require "omnom/engine"
require "omnom/producer"
require "omnom/consumer"

module Omnom
  def start(config)
    Engine.new(config)
  end
end
