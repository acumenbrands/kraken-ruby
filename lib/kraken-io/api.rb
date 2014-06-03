module Kraken
  class API
    include HTTParty
    extend  HTTPMultiPart
    extend  Forwardable

    include StorageProvider
    include Resize
    include Flags

    cattr_accessor :config do
      Kraken.config
    end

    def_delegator :config, :s3, :s3_config
    def_delegator :config, :rackspace, :rackspace_config

    attr_accessor :api_key, :api_secret

    base_uri 'https://api.kraken.io/v1'

    def initialize(api_key = config.api_key, api_secret = config.api_secret)
      @api_key     = api_key
      @api_secret  = api_secret
    end

    def url(url, params = {})
      params = normalized_params(params.merge(url: url))
      call_kraken do
        res = self.class.post('/url', body: params.to_json)
        res = Kraken::Response.new(res)
        yield res if block_given? or return res
      end
    end

    def upload(file_name, params = {})
      params = normalized_params(params)
      call_kraken do
        res = self.class.multipart_post('/upload', file: file_name, body: params.to_json)
        res = Kraken::Response.new(res)
        yield res if block_given? or return res
      end
    end

    private

    def call_kraken(&block)
      if @async
        call_async(&block)
      else
        yield
      end
    end

    def call_async(&block)
      Thread.abort_on_exception = false
      Thread.new do |t|
        block.call
      end
      nil
    end

    def normalized_params(params)
      params = params.with_indifferent_access.merge(auth_hash)

      if params.keys.exclude?(:callback)
        params[:wait] = true
      end

      params[:lossy]        = true if @lossy
      params[:webp]         = true if @webp
      params[:s3]           = Hash[@s3.sort] if @s3
      params[:cf_store]     = Hash[@rackspace.sort] if @rackspace
      params[:callback_url] = @callback_url if @callback_url
      params[:resize]       = Hash[@resize.sort] if @resize

      Hash[params.sort]  #normalize the order
    end

    def auth_hash
      {
        auth: {
          api_key: api_key,
          api_secret: api_secret
        }
      }
    end
  end
end
