Gem::Specification.new do |s|
  s.name = "leonardo"
  s.version = "1.4.0"
  s.date = "2011-08-24"
  s.summary = "A layout and customized scaffold generator for Rails 3.1"
  s.description = "A generator for creating Rails 3.1 applications ready to go. It generates the layout, the style, the internationalization and manage external gems for authentication, authorization and other. It also provides a customized scaffold to generates cool sites ajax ready in few minutes. If you find a bug please report to m.mastrodonato@gmail.com"
  s.homepage = "http://github.com/marcomd/Leonardo"
  s.author = "Marco Mastrodonato"
  s.email = "m.mastrodonato@gmail.com"
  
  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*"] + Dir["test/**/*"] + ["LICENSE", "README.rdoc", "CHANGELOG", "template.rb"]
end
