require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Process do

  def mock_parser
    parser = mock(ImageDownloader::Parser)
    ImageDownloader::Parser.should_receive(:new).with("http://www.test.com", ImageDownloader::Process::DEFAULT_USER_AGENT).and_return(parser)
    parser
  end

  def stub_parser_methods(parser)
    parser.stub!(:get_content_raw)
    parser.stub!(:get_images_raw)
    parser.stub!(:get_content)
    parser.stub!(:get_images)
    parser.stub!(:get_images_regexp)
    parser.stub!(:ignore_file_without)
    parser.stub!(:images)
  end

  before do
    @process = ImageDownloader::Process.new("www.test.com", "tmp/dir/")
  end

  it "should correct normalize url" do
    @process.argument.url.should eq "http://www.test.com"
  end

  it "should correct normalize path" do
    @process.argument.path.should eq "tmp/dir"
  end

  it "should not change correct url and path" do
    process = ImageDownloader::Process.new("http://www.test.com", "/tmp/cc/dir")
    process.argument.url.should eq "http://www.test.com"
    process.argument.path.should eq "/tmp/cc/dir"
  end

  it "parse should call rebuild_collect_hash" do
    @process.should_receive(:rebuild_collect_hash).with(:any_looks_like_image => true, :collect => {:all => true})
    @process.parse(:any_looks_like_image => true, :collect => {:all => true})
  end

  it "user can set any user agent to get web page for parsing" do
    parser = mock(ImageDownloader::Parser)
    ImageDownloader::Parser.should_receive(:new).with("http://www.test.com", "ruby").and_return(parser)
    stub_parser_methods(parser)
    @process.parse(:user_agent => "ruby")
  end

  describe "parse" do

    before do
      @parser = mock_parser
      stub_parser_methods(@parser)
    end

    it "rebuild_collect_hash should change :collect hash for :all and call get_content and get_images" do
      @parser.should_receive(:get_content)
      @parser.should_receive(:get_images).with("tmp/dir", {
          :collect_from_a_href=>true,
          :collect_from_style_url=>true,
          :collect_from_link_icon=>true,
          :collect_from_img_src=>true})
      @process.parse(:collect => {:all => true})
    end

    it "rebuild_collect_hash should change :collect hash for :a_href" do
      @parser.should_receive(:get_content)
      @parser.should_receive(:get_images).with("tmp/dir", {:collect_from_a_href=>true})
      @process.parse(:collect => {:a_href => true})
    end

    it "should parse with regexp if :regexp specified" do
      @parser.should_receive(:get_content_raw)
      @parser.should_receive(:get_images_regexp).with("tmp/dir", /[^'"]+\.jpg/i)
      @process.parse(:regexp => /[^'"]+\.jpg/i)
    end

    it "should call get_content_raw and get_images_raw for :any_looks_like_image" do
      @parser.should_receive(:get_content_raw)
      @parser.should_receive(:get_images_raw)
      @process.parse(:any_looks_like_image => true)
    end

    it "should call ignore and images methods" do
      @parser.should_receive(:ignore_file_without)
      @parser.should_receive(:images)
      @process.parse()
    end

  end

  describe "download" do

    describe "should parallel" do

      before do
        parser = mock(ImageDownloader::Parser)
        ImageDownloader::Download.should_receive(:parallel).and_return(parser)
      end

      it "if no arguments, by default" do
        @process.download
      end
      it "if :parallel as argument" do
        @process.download(:parallel)
      end
      it "if :parallel => true as argument" do
        @process.download(:parallel => true)
      end

    end

    describe "should consequentially" do

      before do
        parser = mock(ImageDownloader::Parser)
        ImageDownloader::Download.should_receive(:consequentially).and_return(parser)
      end

      it "if :consequentially as argument" do
        @process.download(:consequentially)
      end
      it "if :consequentially => true as argument" do
        @process.download(:consequentially => true)
      end

    end

    it "no download if incorrect argument" do
      ImageDownloader::Download.should_not_receive(:consequentially)
      ImageDownloader::Download.should_not_receive(:parallel)
      @process.download(:dab => true)
    end

  end

end
