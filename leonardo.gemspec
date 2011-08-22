Gem::Specification.new do |s|
  s.name = "leonardo"
  s.version = "1.3.1"
  s.date = "2011-08-22"
  s.summary = "A layout and customized scaffold generator for Rails 3.1"
  s.description = "I created a generator for creating Rails applications ready to go. It creates the layout, style, internationalization and manage external gems for authentication, authorization and continuing with all that your project will require. It also provides a customized scaffold to generates cool sites ajax ready in few minutes. If you find a bug please report to m.mastrodonato@gmail.com"
  s.homepage = "http://github.com/marcomd/leonardo"
  s.author = "Marco Mastrodonato"
  s.email = "m.mastrodonato@gmail.com"
  
  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*"] + Dir["test/**/*"] + ["LICENSE", "README.rdoc", "CHANGELOG", "template.rb"]
end
