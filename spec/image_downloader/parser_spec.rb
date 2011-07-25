require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe ImageDownloader::Parser do
  def create_parser(h = {})
    parser = ImageDownloader::Parser.new("http://test.com", "ruby")
    file = h[:nokogiri] ? h[:html] : OpenStruct.new(:read => h[:html])
    parser.stub!(:open_url).and_return(file)
    parser
  end
  def html_prefix
    "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
       <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ru\" lang=\"ru\" class=\"mr-wrap_html\">
         <head>
	         <meta http-equiv=\"X-UA-Compatible\" content=\"IE=8\"/>
         </head>
         <body class=\"body\">"
  end
  def html_suffix
    "  </body>
      </html>"
  end

  describe ".get_images" do
    def create_nokogiri_parser_and_get_images(h = {}, h_collect = {})
      h[:nokogiri] = true
      parser = create_parser(h)
      parser.get_content
      parser.get_images('tmp', h_collect)
      parser
    end
    subject {@parser.images.size}
    context ".collect_from_img_src" do
      context "empty, no content, no images" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => ''}, {:collect_from_img_src => true})
        end
        it {should == 0}
      end
      context "has one <img src='url'>" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<img src=\"http://test.com/img/pic.jpg\">" + html_suffix}, {:collect_from_img_src => true})
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has one <img src=url>" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<img src=http://test.com/img/pic.jpg>" + html_suffix}, {:collect_from_img_src => true})
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has multiple <img src='url'>" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<img src=\"http://test.com/img/pic.jpg\">
               <img src=\"http://test.com/img/pic1.jpg\">" + html_suffix}, {:collect_from_img_src => true})
        end
        it {should == 2}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
        specify {@parser.images[1].file_name.should == 'pic1.jpg'}
        specify {@parser.images[1].absolute_src.should == 'http://test.com/img/pic1.jpg'}
      end
    end
    context ".collect_from_a_href" do
      context "has one <a href='url'>" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<a href=\"http://test.com/img/pic.jpg\">" + html_suffix}, {:collect_from_a_href => true})
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == ImageDownloader::Parser::A_HREF_IMAGE_PREFIX + 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
    end
    context ".collect_from_style_url" do
      context "has one style=\"background: url()\"" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<a href=\"http://test.com/img/pic.jpg\" style=\"background: url(http://test.com/img/pic1.jpg)\">" + html_suffix}, {:collect_from_style_url => true})
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == ImageDownloader::Parser::STYLE_URL_IMAGE_PREFIX + 'pic1.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic1.jpg'}
      end
    end
    context ".collect_from_link_icon" do
      context "has one <link rel='shortcut icon' href='/pic.ico'>" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<link rel='shortcut icon' href='/pic.ico'>" + html_suffix}, {:collect_from_link_icon => true})
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == ImageDownloader::Parser::LINK_ICON_IMAGE_PREFIX + 'pic.ico'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/pic.ico'}
      end
      context "not find pictures in other locations" do
        before do
          @parser = create_nokogiri_parser_and_get_images({:html => html_prefix +
                "<img src=\"http://test.com/img/pic.jpg\">" + html_suffix}, {:collect_from_link_icon => true})
        end
        it {should == 0}
      end
    end
  end
  describe ".get_images_raw" do
    def create_parser_and_get_images(h = {})
      parser = create_parser(h)
      parser.get_content_raw
      parser.get_images_raw('tmp', {})
      parser
    end
    context "html" do
      subject {@parser.images.size}
      context "empty, no content, no images" do
        before do
          @parser = create_parser_and_get_images(:html => '')
        end
        it {should == 0}
      end
      context "no empty, have not images" do
        before do
          @parser = create_parser_and_get_images(:html => '<head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=8\"/></head>')
        end
        it {should == 0}
      end
      context "has one <img src='url'>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=\"http://test.com/img/pic.jpg\">" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has one <img src='url?tgd23dfg'>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=\"http://test.com/img/pic.jpg?tgd23dfg\">" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has one <img src=url>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=http://test.com/img/pic.jpg>" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has one <a href=url>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<a href=http://test.com/img/pic.jpg>" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has one <img src=url?rnd=214312718&ts=1311344507>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=http://test.com/img/pic.jpg?rnd=214312718&ts=1311344507>" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has one 'background:url(img/pic.gif)'" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<td style=\"background:url(img/pic.gif) no-repeat bottom left;\" valign=\"bottom\" align=\"center\">" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.gif'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.gif'}
      end
      context "has one background:url(img/pic.gif)" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<td style=background:url(img/pic.gif) no-repeat bottom left; valign=\"bottom\" align=\"center\">" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.gif'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.gif'}
      end
      context "has multiple identical <img src=''>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=\"http://test.com/img/pic.jpg\">
               <img src=\"http://test.com/img/pic.jpg\">" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
      end
      context "has multiple different <img src=''>" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=\"http://test.com/img/pic.jpg\">
               <img src=\"http://test.com/img/pic1.jpg\">" + html_suffix)
        end
        it {should == 2}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
        specify {@parser.images[1].file_name.should == 'pic1.jpg'}
        specify {@parser.images[1].absolute_src.should == 'http://test.com/img/pic1.jpg'}
      end
      ImageDownloader::Images::IMAGE_EXTENSIONS.each do |format|
        context "has one image format: #{format}" do
          before do
            @parser = create_parser_and_get_images(:html => html_prefix +
                "<img src=\"http://test.com/img/pic.#{format}\">" + html_suffix)
          end
          it {should == 1}
          specify {@parser.images.first.file_name.should == "pic.#{format}"}
          specify {@parser.images.first.absolute_src.should == "http://test.com/img/pic.#{format}"}
        end
      end
      context "has multiple images format: jpg, png" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<img src=\"http://test.com/img/pic.jpg\">
               <img src=\"http://test.com/img/pic1.png\">" + html_suffix)
        end
        it {should == 2}
        specify {@parser.images.first.file_name.should == 'pic.jpg'}
        specify {@parser.images.first.absolute_src.should == 'http://test.com/img/pic.jpg'}
        specify {@parser.images[1].file_name.should == 'pic1.png'}
        specify {@parser.images[1].absolute_src.should == 'http://test.com/img/pic1.png'}
      end
    end
    context "js in html" do
      subject {@parser.images.size}
      context "image in string" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<script>\"http:\\/\\/test.ru\\/90\\/f0\\/111d4942fadcb1dbf3c1adeb5e06f090.jpg\"</script>" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == "111d4942fadcb1dbf3c1adeb5e06f090.jpg"}
        specify {@parser.images.first.absolute_src.should == "http:%5C/%5C/test.ru%5C/90%5C/f0%5C/111d4942fadcb1dbf3c1adeb5e06f090.jpg"}
      end
      context "image have generated suffix" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<script>\"http://test.com/img/pic.jpg?ert4523464hfsr4\"</script>" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == "pic.jpg"}
        specify {@parser.images.first.absolute_src.should == "http://test.com/img/pic.jpg"}
      end
      context "case insensitive image format and name" do
        before do
          @parser = create_parser_and_get_images(:html => html_prefix +
              "<script>\"http://test.com/img/Pic.JPG\"</script>" + html_suffix)
        end
        it {should == 1}
        specify {@parser.images.first.file_name.should == "Pic.JPG"}
        specify {@parser.images.first.absolute_src.should == "http://test.com/img/Pic.JPG"}
      end
    end
  end

  describe ".get_images_regexp" do
    def create_parser_and_get_images(h = {}, regexp = nil)
      parser = create_parser(h)
      parser.get_content_raw
      parser.get_images_regexp('tmp', regexp)
      parser
    end
    subject {@parser.images.size}
    context "find img with regexp /[^'\"]+\.jpg/" do
      before do
        @parser = create_parser_and_get_images({:html => html_prefix +
            '<img src="http://test.com/img/pic.jpg">' + html_suffix}, /[^'"]+\.jpg/)
      end
      it {should == 1}
      specify {@parser.images.first.file_name.should == "pic.jpg"}
      specify {@parser.images.first.absolute_src.should == "http://test.com/img/pic.jpg"}
    end
    # not work with () for ruby 1.9.2 example: ['"]([^'\"]+\.css)[^'"]+['"]
    context "find css with regexp /[^'\"]+\.css/" do
      before do
        @parser = create_parser_and_get_images({:html => html_prefix +
            "<link href=\"/stylesheets/blueprint/test.css?1291142702\"
              media=\"print\" rel=\"stylesheet\" type=\"text/css\" /> " + html_suffix},
          /[^'"]+\.css/)
      end
      it {should == 1}
      specify {@parser.images.first.file_name.should == "test.css"}
      specify {@parser.images.first.absolute_src.should == "http://test.com/stylesheets/blueprint/test.css"}
    end
  end

end