# gems
require 'nokogiri'
# core lib
require 'open-uri'
require 'thread'
require 'uri'
require 'net/http'
require 'optparse'
# local lib
require 'image_downloader/images'
require 'image_downloader/url'
require 'image_downloader/arguments'
require 'image_downloader/parser'
require 'image_downloader/download'

module ImageDownloader

  options = {}
  OptionParser.new do |opts|
    opts.on("-d", "--debug", "Run debug mode") do |d|
      options[:debug] = d
      $debug_option = true
    end
  end.parse!
  
  class Process
    attr_accessor :argument, :images

    def initialize(url, path)
      @argument = Arguments.new(url, path)
      @argument.check
      @argument.normalize
      @images = []
    end

    # :any_looks_like_image => true
    # :ignore_without => {:(extension|image_extension) => true}
    # Nokogiri gem is required:
    # :collect => {:all => true, :(img_src|a_href|style_url|link_icon) => true},
    def parse(h={:collect => {}, :ignore_without => {}})
      self.rebuild_collect_hash(h)

      parser = Parser.new(self.argument.url)
      if h[:any_looks_like_image]
        parser.get_content_raw
        parser.get_images_raw(self.argument.path, h[:collect])
      else
        parser.get_content
        parser.get_images(self.argument.path, h[:collect])
      end

      parser.ignore_file_without(h[:ignore_without])

      self.images = parser.images
    end

    # :(parallel|consequentially)
    def download(*args)
      if !args.first || args.first == :parallel
        Download.parallel(self.images)
      elsif args.first == :consequentially
        Download.consequentially(self.images)
      end
    end

    protected

    def rebuild_collect_hash(h={})
      if !h[:collect] || h[:collect].empty? || h[:collect][:all]
        h[:collect] = Parser.all_image_places
      else
        collect_new = {}
        h[:collect].each_key{|k|
          collect_new[(Parser::COLLECT_METHODS_PREFIX + k.to_s).to_sym] = true
        }
        h[:collect].merge!(collect_new)
        h[:collect].delete_if{|k,v| !Parser.all_image_places.has_key?(k)}
      end
    end

  end
end