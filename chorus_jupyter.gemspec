#encoding: UTF-8
Gem::Specification.new do |s|
  s.name          = "chorus_jupyter"
  s.email         = "msouza@alpinenow.com "
  s.version       = "0.0.1"
  s.date          = "2016-03-30"
  s.description   = "Support for jupyter notebook API interaction"
  s.summary       = "Jupyter notebook API integration"
  s.authors       = ["Michael Souza"]
  s.homepage      = "http://alpinenow.com"
  s.license       = "NONE"

  # files = []
  # files << "readme.md"
  # files << Dir["sql/**/*.sql"]
  # files << Dir["{lib,test}/**/*.rb"]
  # s.files = files
  # s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.require_paths = %w[chorus_jupyter]
  s.add_dependency "httparty"
  s.add_dependency "contractual"
end