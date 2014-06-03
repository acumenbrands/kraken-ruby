module ActiveSupport
  module Configurable
    module ClassMethods
      def config_accessor(*names)
        options = names.extract_options!

        names.each do |name|
          raise NameError.new('invalid config attribute name') unless name =~ /\A[_A-Za-z]\w*\z/

          reader, reader_line = "def #{name}; config.#{name}; end", __LINE__
          writer, writer_line = "def #{name}=(value); config.#{name} = value; end", __LINE__

          singleton_class.class_eval reader, __FILE__, reader_line
          singleton_class.class_eval writer, __FILE__, writer_line

          unless options[:instance_accessor] == false
            class_eval reader, __FILE__, reader_line unless options[:instance_reader] == false
            class_eval writer, __FILE__, writer_line unless options[:instance_writer] == false
          end
          send("#{name}=", yield) if block_given?
        end
      end
    end
  end
end
