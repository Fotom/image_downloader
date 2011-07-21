require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageDownloader::Images do

  before do
          @test_host = "www.test.com"
      @src = "http://www.test.com/images/pic.jpg"
      @h = {:catalog_path => 'tmp', :file_name_prefix =>  ''}
  end

  context "when correct" do
    before do
      @image = ImageDownloader::Images.new(@test_host, @src, @h)
    end
    it "set file name" do
      @image.file_name.should == 'pic.jpg'
    end
    it "set file_path_name" do
      @image.file_path_name.should == 'tmp/pic.jpg'
    end
    it "set absolute_src" do
      @image.absolute_src.should == 'http://www.test.com/images/pic.jpg'
    end
    it "set prefix if exist" do
      @h[:file_name_prefix] = 'prefix_'
      image = ImageDownloader::Images.new(@test_host, @src, @h)
      image.file_name.should == 'prefix_pic.jpg'
    end
    it "set self host if not host in src"do
      image = ImageDownloader::Images.new(@test_host, '/images/icon.ico', @h)
      image.absolute_src.should == 'http://www.test.com/images/icon.ico'
    end
  end

  context "when incorrect" do
    it "generate file name" do
      image = ImageDownloader::Images.new(@test_host, '', @h)
      image.file_name.should be
    end
    it "file name like standart name" do
      image = ImageDownloader::Images.new(@test_host, '', @h)
      image.file_name.should =~ /#{ImageDownloader::Images::EMPTY_FILE_NAME}/
    end
    it "file name different for two empty files" do
      image = ImageDownloader::Images.new(@test_host, '', @h)
      image1 = ImageDownloader::Images.new(@test_host, '', @h)
      image.file_name.should_not == image1.file_name
    end
    it "cut too long file_name" do
      1.upto(1000) {@src.insert(-7,'x')}
      image = ImageDownloader::Images.new(@test_host, @src, @h)
      image.file_name.length.should <= ImageDownloader::Images::MAX_FILE_NAME_LENGTH_ALLOWED
    end
  end

end