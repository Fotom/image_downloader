module ImageDownloader
  class URL

    def self.contain_http?(url)
      url =~ /^(http|https)/i ? true : false
    end

    def self.normalize(url)
      contain_http?(url) ? url : 'http://' + url
    end

    def self.remove_new_line_symbols!(str)
      str.gsub!(/\r/,'') if str
      str.gsub!(/\n/,'') if str
    end

  end
end
