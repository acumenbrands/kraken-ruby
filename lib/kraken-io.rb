require 'json'
require 'httparty'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/enumerable'
require 'active_support/configurable'
require 'thread'
require 'forwardable'

if ActiveSupport::VERSION::MAJOR < 4
  require "kraken-io/configurable"
end

require 'kraken-io/http_multi_part'
require 'kraken-io/response'
require 'kraken-io/storage_provider'
require 'kraken-io/resize'
require 'kraken-io/flags'
require 'kraken-io/config'
require 'kraken-io/api'

module Kraken
  Client = API
end
