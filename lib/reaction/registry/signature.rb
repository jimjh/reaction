module Reaction
  class Registry

    # Signature for secure channel subscription.
    # When a client accesses a published controller, it's given a channel ID
    # and signature. The signature is calculated as follows:
    #
    #       signature = SHA1-HMAC(secret, channel_id + salt)
    #
    # where +secret+ is a generated secret that is kept in the user's session,
    # and +salt+ is a secret token provided by the framework (in Rails, this
    # would be +Rails.application.config.secret_token+). This signature is
    # invalidated when the user's session is reset, preventing channel
    # fixation.
    # @!attribute [r] secret
    #   Signature secret.
    class Signature

      class << self

        # Generates channel ID, signature and secret using the given token.
        # @param [String] salt     secret token, used as salt
        # @return [Array] channel ID, signature, and secret
        def generate(salt)
          channel_id = SecureRandom.uuid
          signature = Signature.new salt: salt, channel_id: channel_id
          return channel_id, signature.to_s, signature.secret
        end

        # Validates the given signature.
        # @param [String] expected    expected signature
        # @param [Hash] opts          see Signature#new.
        def validate(expected, opts)
          actual = Signature.new(opts).to_s
          return actual == expected
        end

      end

      attr_reader :secret

      # Creates a new signature. If a secret is not provided, it will be
      # generated.
      # @option opts [String] :salt                 secret token
      # @option opts [String] :channel_id           channel ID
      # @option opts [String] :secret (generated)   signature secret
      def initialize(opts)
        @salt = opts[:salt]
        @channel_id = opts[:channel_id]
        @secret = opts[:secret] || SecureRandom.hex
      end

      # Calculates SHA1-HMAC.
      # @return [String] signature
      def to_s
        digest = OpenSSL::Digest::Digest.new('sha1')
        OpenSSL::HMAC.hexdigest(digest, @secret, @channel_id + @salt)
      end

    end

  end
end
