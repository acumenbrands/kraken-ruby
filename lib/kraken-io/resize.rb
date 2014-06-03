module Kraken
  class API
    module Resize
      [:crop, :exact, :auto, :portrait, :landscape].each do |strategy|
        define_method(strategy) do
          @resize ||= {}
          @resize['strategy'] = strategy.to_s
          self
        end
      end

      def resize(options = {})
        options = options.with_indifferent_access.slice(:width, :height)

        if options.keys != ['width', 'height']
          raise ArgumentError, ":width and :height are both required"
        end

        @resize ||= {}
        @resize.reverse_merge! options

        self
      end
    end
  end
end
