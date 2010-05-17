require 'date'

module Kharites
  class Article

    class << self

      # Creates OpenStrucs for all articles
      #
      # Example:
      # 
      # <tt>Kharites::Article.all.each { |article| puts article.title }<tt>
      def all
        articles = []
        extract_articles_from_directories.each do |file|
          article = extract_article_info_from(file)
          articles << article
        end
        return articles.reverse
      end

      # Returns an OpenStruct of an specific article searched by slug
      #
      # Example
      #
      # <tt>Kharites::Article.find_one("slug").title<tt>
      def find_one(slug)
        directory = Configuration.data_directory + "/" + slug
        return if directory.nil? or !File.exist?(directory)
        file = Dir["#{directory}/*.yml"].first
        extract_article_info_from(file)
      end
    end #self public

    private

    class << self

      # Returns an array with all articles directories
      def load_articles_directories
        Dir[File.join(Configuration.data_directory, '*')].select { |dir| File.directory?(dir) }.sort
      end

      # Returns an array with all the articles .yml files
      def extract_articles_from_directories
        directories = []
        load_articles_directories.each do |dir| 
          file = Dir["#{dir}/*.yml"].first
          directories << file          
        end
        return directories
      end

      # Returns an article OpenStruct based on the .yml file
      def extract_article_info_from(file)
        raise ArgumentError, "#{file} is not a readable file" unless File.exist?(file) and File.readable?(file)
        raw_config = YAML.load_file(file)
        @@config   = nested_hash_to_openstruct(raw_config)
      end

      # Verifies if an specific method can be build with an OpenStuct.
      # If not, it should be handle by parent class.
      def method_missing(method_name, *attributes)
        if @@config.respond_to?(method_name.to_sym)
          return @@config.send(method_name.to_sym)
        else
          super
        end
      end

      # Returns an OpenStruct based on the article .yml file
      def nested_hash_to_openstruct(obj)
        if obj.is_a? Hash
          obj.each { |key, value| obj[key] = nested_hash_to_openstruct(value) }
          OpenStruct.new(obj)
        else
          return obj
        end
      end
    end #self private
  end #Article
end #Kharites
