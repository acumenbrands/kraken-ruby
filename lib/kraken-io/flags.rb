module Kraken
  class API
    module Flags

      def async
        @async = true
        self
      end

      def sync
        @async = false
        self
      end

      def webp
        @webp = true
        self
      end

      def lossy
        @lossy = true
        self
      end

      def callback_url(url)
        @callback_url = url
        self
      end
    end
  end
end
