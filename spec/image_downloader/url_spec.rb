require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageDownloader::URL do

  it "false for url without http" do
    ImageDownloader::URL.contain_http?('www.test.com').should == false
  end
  it "true for url with http" do
    ImageDownloader::URL.contain_http?('http://www.test.com').should == true
  end
  it "true for url with https" do
    ImageDownloader::URL.contain_http?('https://www.test.com').should == true
  end

  it "should normalize url without http" do
    ImageDownloader::URL.normalize('www.test.com').should == "http://www.test.com"
  end
  it "should not change url with http" do
    ImageDownloader::URL.normalize('http://www.test.com').should == "http://www.test.com"
  end
  it "should not change url with https" do
    ImageDownloader::URL.normalize('https://www.test.com').should == "https://www.test.com"
  end

  it "should remove \\n and \\r from string" do
    ImageDownloader::URL.remove_new_line_symbols!("www.te\rst.c\nom").should == "www.test.com"
  end

end