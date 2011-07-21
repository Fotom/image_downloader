module ImageDownloader
  class Images
    attr_accessor :src, :file_name, :page_host, :absolute_src, :file_path_name

    MAX_FILE_NAME_LENGTH_ALLOWED = 200
    IMAGE_EXTENSIONS = ["jpg","jpeg","png","gif","ico","svg","bmp"]
    EMPTY_FILE_NAME = 'EMPTY_'

    def initialize(page_host,src,h = {})
      @page_host = page_host
      @src = src

      # for fix Errno::ENAMETOOLONG & empty file name
      file_name_suffix = @src.sub(/.*\//,'')
      file_name_suffix = EMPTY_FILE_NAME + rand(100000).to_s if !file_name_suffix || file_name_suffix.empty?
      if file_name_suffix.size > MAX_FILE_NAME_LENGTH_ALLOWED
        file_name_suffix = file_name_suffix[-MAX_FILE_NAME_LENGTH_ALLOWED..file_name_suffix.size]
      end

      @file_name = h[:file_name_prefix] + file_name_suffix
      @file_path_name = h[:catalog_path] + '/' + @file_name
      @absolute_src = ((@src =~ /http/) ? @src : ('http://' + page_host + '/' +  @src.sub(/^\/+/,'')))
    end

    def download(user_agent)
      url = URI.parse(self.absolute_src)
      request = Net::HTTP::Get.new(url.path)
      Net::HTTP.start(url.host) {|http|
        # for exclude 403 and 404 errors from web servers (e.g. detect current client as script)
        # you can use:
        # - watir (with js support and other ...), but vary vary slow
        # - mechanize (main web client), slow
        # - wget, quick, but cannot support some ability (403, 404 responses)
        # - sockets, independent request, quick, but low-level (many lines of code)
        self.download_by_segment(http,request,user_agent)
        # self.download_simple(http,request,user_agent)
      }
    rescue URI::InvalidURIError
      p "Error: bad URI: #{self.absolute_src}"  if $debug_option
    end

    def download_by_segment(http,request,user_agent)
      file = open(self.file_path_name, "wb")
      begin
        http.request_get(request.path, "User-Agent"=> user_agent) do |response|
          response.read_body do |segment|
            file.write(segment)
          end
        end
      ensure
        file.close()
      end
    end

    def download_simple(http,request,user_agent)
      response = http.get(request.path, "User-Agent"=> user_agent)
      open(self.file_path_name, "wb") { |file|
        file.write(response.body)
      }
    end

  end
end