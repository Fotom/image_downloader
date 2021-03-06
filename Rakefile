# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "image_downloader"
  gem.homepage = "http://github.com/Fotom/image_downloader"
  gem.license = "MIT"
  gem.summary = %Q{Lib for parsing web pages to find images in specified locations and downloading them simultaneously or sequentially. Picture downloader and grabber for images, photos, pictures (.jpg, .jpeg, .png, .gif, .ico, .svg, .bmp)...}
  gem.description = %Q{A simple lib for downloading pictures from web pages. It can get and parse page with different options and receive images from specified locations. It is possible to download images simultaneously in multiple threads or sequentially.

  In fact, it's picture downloader or picture grabber from web pages, which allows you to download photos (.jpg, .jpeg, .png, .gif, .ico, .svg, .bmp) and not only them.}
  gem.email = "malykholeg@gmail.com"
  gem.authors = ["Malykh Oleg"]
  #  load lib files
  gem.files = Dir.glob('lib/**/*.rb')
  # executable like shell script in bin/ dir
  gem.executables = ['download_any_images', 'download_images', 'download_icon', 'download_by_regexp']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "image_downloader #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
