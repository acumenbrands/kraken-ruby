module Kraken
  class API
    module StorageProvider
      def s3(bucket, options = {})
        options = options.with_indifferent_access.slice(:acl, :path)

        raise AuthenticationError, "Your S3 Credentials are not set" unless s3_config.set?

        @s3 = ({
          key: s3_config.api_key,
          secret: s3_config.api_secret,
          bucket: bucket
        }.with_indifferent_access)

        unless options[:acl].presence.in? [:public_read, :private, nil]
          raise ArgumentError, "`acl` options must be set to :public_read or :private"
        end

        @s3.reverse_merge! options

        self
      end

      def rackspace(container, options = {})
        options = options.with_indifferent_access.slice(:path)

        raise AuthenticationError, "Your Rackspace Credentials are not set" unless rackspace_config.set?

        @rackspace = ({
          key: rackspace_config.api_key,
          secret: rackspace_config.api_secret,
          container: container
        }.with_indifferent_access)

        @rackspace.reverse_merge! options

        self
      end

    end
  end
end
