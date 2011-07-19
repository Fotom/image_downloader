module ImageDownloader
  class Download

    def self.parallel(images, user_agent)
      threads = []
      for image in images
        threads << Thread.new(image) {|local_image|
          p "upload from url #{local_image.absolute_src} to file #{local_image.file_name}" if $debug_option
          local_image.download(user_agent)
        }
      end
      threads.each { |aThread|  aThread.join }
    end

    def self.consequentially(images, user_agent)
      for image in images
        p "upload from url #{image.absolute_src} to file #{image.file_name}" if $debug_option
        image.download(user_agent)
      end
    end

  end
end