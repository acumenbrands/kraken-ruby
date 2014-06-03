module Kraken
  class AuthenticationError < StandardError; end

  class Credentials < Struct.new(:api_key, :api_secret, :service)
    def set?
      [api_key, api_secret].all?
    end
  end

  include ActiveSupport::Configurable
  config_accessor :api_key, :api_secret

  config_accessor :s3 do
    Kraken::Credentials.new.tap do |cred|
      cred.service = :s3
    end
  end

  config_accessor :rackspace do
    Kraken::Credentials.new.tap do |cred|
      cred.service = :rackspace
    end
  end
end
