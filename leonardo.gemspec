Gem::Specification.new do |s|
  s.name = "leonardo"
<<<<<<< HEAD
  s.version = "1.9.0"
  s.date = "2011-12-13"
=======
  s.version = "1.7.0"
  s.date = "2011-09-28"
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798
  s.summary = "A layout and customized scaffold generator for Rails 3.1"
  s.description = "A generator for creating Rails 3.1 applications ready to go. It generates the layout, the style, the internationalization and manage external gems for authentication, authorization and other. It also provides a customized scaffold to generates cool sites ajax ready in few minutes. If you find a bug please report to m.mastrodonato@gmail.com"
  s.homepage = "http://github.com/marcomd/Leonardo"
  s.authors = ["Marco Mastrodonato"]
  s.email = "m.mastrodonato@gmail.com"
  s.requirements = "Start a new app with the template.rb from github or inside root folder"
  
  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*"] + Dir["test/**/*"] + ["LICENSE", "README.rdoc", "CHANGELOG", "template.rb"]
end
