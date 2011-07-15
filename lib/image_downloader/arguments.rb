module ImageDownloader
  class Arguments
    attr_accessor :url, :path

    def initialize(url, path)
      @url = url
      @path = path
    end

    def check
      if !self.url
        p "Not specified url"
        exit
      end
      if !self.path
        p "Not specified path"
        exit
      end
    end

    def normalize
      self.url = URL.normalize(self.url)
      self.path = self.path.gsub(/\/+$/,'')
    end

  end
end
