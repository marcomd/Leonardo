#This is a Rails 3.1.x template
#Written by Marco Mastrodonato  27/07/2011
#
# USAGE: rails new yourapp -m template.rb

puts '*' * 40
puts "* Processing template..."
puts '*' * 40

use_git = yes?("Do you think to use git ?")
if use_git
  git :init
  file ".gitignore", <<-EOS.gsub(/^    /, '')
    .DS_Store
    log/*.log
    tmp/**/*
    config/database.yml
    db/*.sqlite3
    nbproject/*
    .idea
  EOS
end

gem 'kaminari' if yes?("Pagination ?")

gem 'paperclip' if yes?("Attachment ?")

gem 'fastercsv' if yes?("FasterCSV ?")

gem 'state_machine' if yes?("Do you have to handle states ?")

formtastic = yes?("Formtastic ?")
if formtastic
  #gem 'justinfrench-formtastic', :lib => 'formtastic', :source => 'http://gems.github.com'
  #rake "gems:install" if install_gem

  #A Rails FormBuilder DSL (with some other goodies) to make it far easier to create beautiful, semantically rich, syntactically awesome, readily stylable and wonderfully accessible HTML forms in your Rails applications.
  gem 'formtastic'
  gem 'validation_reflection'
end

if yes?("Add testing framework ?")
  gem 'rspec-rails', :group => :test
  gem 'capybara', :group => :test
  gem 'launchy', :group => :test
end

model_name = nil
devise = yes?("Would you like to install Devise?")
if devise
  gem 'devise'
  model_name = ask(" What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
end

cancan = yes?("Authorization ?")
gem 'cancan' if cancan

#home = yes?("Generate controller home ? (raccomanded)")
home = true

leolay = yes?("Layout ?")
leolay_main_color = leolay_second_color = nil
if leolay
  gem 'leonardo'
  puts " Enter colors, for example:"
  puts "   #c8c8c8 or rgb(200,200,200) or gray"
  leolay_main_color = ask(" Choose main color [blank=default color]:")
  leolay_second_color = ask(" Choose secondary color [blank=default color]:")
end

run "bundle install"

generate "formtastic:install" if formtastic

if devise
  generate("devise:install")
  generate("devise", model_name)
  #generate("devise:views") #not use since leolay copies custom views
end

generate "cancan:ability" if cancan

if leolay
  generate  "leolay",
            (leolay_main_color && leolay_main_color.any? ? leolay_main_color : ""),
            (leolay_second_color && leolay_second_color.any? ? leolay_second_color : ""),
            (cancan ? "" : "--skip-authorization"),
            (devise ? "" : "--skip-authentication"),
	          (formtastic ? "" : "--skip-formtastic")
end

if home
  generate "controller", "home", "index"
  route "root :to => 'home#index'"
end

File.unlink "public/index.html"

rake "db:create:all"
rake "db:migrate"

#rake "gems:unpack" if yes?("Unpack to vendor/gems ?")

git :add => ".", :commit => "-m 'initial commit'" if use_git

puts "ENJOY!"
