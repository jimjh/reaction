module Reaction

  # Adapter for Rack-based applications. Currently supports starting a reaction
  # server in-process.
  # --
  # TODO: support starting external reaction servers.
  class RackAdapter < Faye::RackAdapter
  end

end
