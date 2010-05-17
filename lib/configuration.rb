require 'yaml'
require 'ostruct'
require 'pathname'

KHARITES_ROOT = File.join(File.expand_path(File.dirname(__FILE__)), '..') unless defined?(KHARITES_ROOT)

module Kharites
  class Configuration
    class << self
      def load
        raw_config = YAML.load_file( File.join(KHARITES_ROOT, 'config', 'config.yml') )
        @@config   = nested_hash_to_openstruct(raw_config)
      end

      def revision
        sha = File.read( File.join(KHARITES_ROOT, 'REVISION') ) rescue nil
        if sha
          @@revision ||= Githubber.new(KHARITES_ROOT).revision( sha.chomp )
        else
          nil
        end
      end

      def data_directory_path
        Pathname.new( File.join(KHARITES_ROOT, data_directory) )
      end

      def method_missing(method_name, *attributes)
        if @@config.respond_to?(method_name.to_sym)
          return @@config.send(method_name.to_sym)
        else
          super
        end
      end
    end #self

    private

    def self.nested_hash_to_openstruct(obj)
      if obj.is_a? Hash
        obj.each { |key, value| obj[key] = nested_hash_to_openstruct(value) }
        OpenStruct.new(obj)
      else
        return obj
      end
    end

  end #Configuration
  Configuration.load
end #kharites
