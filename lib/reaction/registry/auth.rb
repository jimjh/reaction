module Reaction

  class Registry

    # Authentication Module.
    module Auth

      class << self

        # Generates an access token using the given options.
        #       SHA256(channel_id + date + user-agent + csrf + salt)
        #
        # All options are required.
        # @option opts [String] :channel_id channel ID
        # @option opts [String] :date       date string
        # @option opts [String] :user_agent user agent string from client
        # @option opts [String] :csrf       CSRF token from Rails
        # @option opts [String] :salt       security salt from Rails
        # @return [String]                  access token
        def generate_token(opts)
          components = [:channel_id, :date, :user_agent, :csrf, :salt]
          return Digest::SHA2.hexdigest(components.reduce("") { |s, opt| s += opts[opt] })
        end

      end

    end

  end

end
