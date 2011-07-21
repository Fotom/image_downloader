require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageDownloader::Download do

  before do
    @image = ImageDownloader::Images.new("www.test.com", "http://www.test.com/images", {
        :catalog_path => 'tmp',
        :file_name_prefix =>  ''})
    @image1 = ImageDownloader::Images.new("www.test1.com", "http://www.test1.com/images", {
        :catalog_path => 'tmp1',
        :file_name_prefix =>  '1'})
    @image.stub!(:download)
    @image1.stub!(:download)
  end


  describe "parallel" do
    it "should call threads new" do
      thread = Thread.new(@image){|local_image| true}
      Thread.should_receive(:new).with(@image).and_return(thread)
      ImageDownloader::Download.parallel([@image], "ruby")
    end

    it "should call image download" do
      @image.should_receive(:download)
      ImageDownloader::Download.parallel([@image], "ruby")
    end

    it "should call image download for all images" do
      @image.should_receive(:download)
      @image1.should_receive(:download)
      ImageDownloader::Download.parallel([@image, @image1], "ruby")
    end
  end

  describe "consequentially" do
    it "should not call threads new" do
      Thread.should_not_receive(:new)
      ImageDownloader::Download.consequentially([@image], "ruby")
    end

    it "should call image download for all images" do
      @image.should_receive(:download)
      @image1.should_receive(:download)
      ImageDownloader::Download.consequentially([@image, @image1], "ruby")
    end
  end

end