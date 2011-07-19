class Array
  def to_hash_keys(&block)
    Hash[*self.collect { |v|
        [v, block.call(v)]
      }.flatten]
  end

  def to_hash_values(&block)
    Hash[*self.collect { |v|
        [block.call(v), v]
      }.flatten]
  end
end

module ImageDownloader
  class Parser
    attr_accessor :url, :argument_url, :content, :images, :images_hash, :user_agent

    A_HREF_IMAGE_PREFIX = '_a_href_'
    STYLE_URL_IMAGE_PREFIX = '_style_url_'
    LINK_ICON_IMAGE_PREFIX = '_link_icon_'
    COLLECT_METHODS_PREFIX = 'collect_from_'

    def initialize(url, user_agent)
      @argument_url = url
      @user_agent = user_agent
      @url = URI.parse(url)
      @images = []
      @images_hash = {}
    end

    def get_content_raw
      @content = open(self.argument_url, 'User-Agent' => self.user_agent).read
      @content.gsub!(/[\n\r\t]+/,' ')
    end

    def get_images_raw(path,h={})
      self.content.scan(/['"]+[^'"]+\.(?:#{Images::IMAGE_EXTENSIONS.join('|')})['"]+/).map{|src|
        src.gsub!(/['"]/,'')
        self.push_to_images(path,src)
      }
    end

    def get_images_regexp(path,regexp)
      self.content.scan(regexp) {|src| self.push_to_images(path,src.to_s)}
    end

    def get_content
      @content = Nokogiri::HTML(open(self.argument_url, 'User-Agent' => self.user_agent))
    end

    def get_images(path,h={})
      h.each_key{|key| self.send(key, path)}
    end

    def collect_from_img_src(path)
      self.content.xpath('//img').each do |img|
        src = img[:src]
        URL.remove_new_line_symbols!(src)
        self.push_to_images(path,src)
      end
    end

    def collect_from_a_href(path)
      self.content.xpath('//a').each do |a|
        href = a[:href]
        URL.remove_new_line_symbols!(href)
        next if href !~ /\.(?:#{Images::IMAGE_EXTENSIONS.join('|')})/i
        self.push_to_images(path,href,{:file_name_prefix => A_HREF_IMAGE_PREFIX})
      end
    end

    def collect_from_style_url(path)
      self.content.xpath("//*[@style]").each do |element|
        style = element[:style]
        next if style !~ /(?:background|background-image):\s*url\(['"]?(.*?)['"]?\)/i
        src = $1
        next if !src
        URL.remove_new_line_symbols!(src)
        self.push_to_images(path,src,{:file_name_prefix => STYLE_URL_IMAGE_PREFIX})
      end
    end

    def collect_from_link_icon(path)
      self.content.xpath('//link[@rel="shortcut icon"]').each do |link|
        src = link[:href]
        URL.remove_new_line_symbols!(src)
        self.push_to_images(path,src,{:file_name_prefix => LINK_ICON_IMAGE_PREFIX})
      end
    end

    def push_to_images(path,src,h={})
      if !self.images_hash.has_key?(src)
        self.images_hash[src] = 1
        self.images.push Images.new(self.url.host,URI.escape(src), {
            :catalog_path => path,
            :file_name_prefix =>  (h[:file_name_prefix] || '')})
      end
    end

    def ignore_file_without(h={})
      return if !h
      self.images.delete_if {|image| image.file_name !~ /\.[a-z]{0,5}$/i } if h[:extension]
      self.images.delete_if {|image| image.file_name !~ /\.(?:#{Images::IMAGE_EXTENSIONS.join('|')})$/i } if h[:image_extension]
    end

    def self.all_collect_from_methods
      Parser.instance_methods.select{|m| m =~ /#{COLLECT_METHODS_PREFIX}/}.map{|m| m.to_sym}.to_hash_keys{true}
    end

    class << self
      alias all_image_places all_collect_from_methods
    end

  end
end