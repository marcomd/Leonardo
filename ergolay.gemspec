Gem::Specification.new do |s|
  s.name = 'ergolay'
  s.version = '1.0.0'
  s.date = '2011-08-02'
  s.summary = 'A layout and customized scaffold generator for Rails 3.1'
  s.description = 'Generate a layout using the ERGO Insurance Group\'s style, you can customize it or add your own. It also provides a customized scaffold to generates cool sites ajax ready.'
  s.homepage = "http://github.com/marcomd/ergolay"
  s.author = "Marco Mastrodonato"
  s.email = "m.mastrodonato@gmail.com"
  
  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*"] + Dir["test/**/*"] + ["LICENSE", "README.rdoc", "CHANGELOG"]
end
