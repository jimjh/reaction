module Reaction

  # Reaction-Rails
  module Rails
    # register our special mime type with rails
    Mime::Type.register 'application/vnd.reaction.v1', :reaction
  end

end
