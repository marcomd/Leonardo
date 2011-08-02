class ErgolayGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :style, :type => :string, :default => "ergo"
  class_option :pagination, :type => :boolean, :default => true, :description => "Include pagination files"
  class_option :main_color, :type => :string, :default => nil, :description => "Force a main color for the stylesheet"
  class_option :second_color, :type => :string, :default => nil, :description => "Force a secondary color for the stylesheet"
  #class_option :scaffolding, :type => :boolean, :default => true, :description => "Update original scaffolding"
  class_option :authentication, :type => :boolean, :default => true, :description => "Add code to manage authentication with devise"
  class_option :authorization, :type => :boolean, :default => true, :description => "Add code to manage authorization with cancan"

  def generate_layout
    template "config.rb", "config/initializers/config.rb"

    template "#{style_name}/stylesheet.sass",
             "app/assets/stylesheets/#{style_name}.sass"

    copy_file "layout_helper.rb", "app/helpers/layout_helper.rb"

    copy_file "#{style_name}/views/layout/application.html.erb", "app/views/layouts/application.html.erb"
    template "#{style_name}/views/layout/_layout.html.erb", "app/views/layouts/_#{style_name}.html.erb"
              #{:authentication => options.authentication?,
              #:authorization => options.authorization?}
    copy_file "#{style_name}/views/layout/_message.html.erb", "app/views/application/_message.html.erb"
    copy_file "#{style_name}/views/layout/_session.html.erb", "app/views/application/_session.html.erb" if options.authentication?

    copy_file "locales/en.yml", "config/locales/en.yml"
    copy_file "locales/it.yml", "config/locales/it.yml"

    if options.pagination?
      copy_file "locales/kaminari.en.yml", "config/locales/kaminari.en.yml"
      copy_file "locales/kaminari.it.yml", "config/locales/kaminari.it.yml"

      copy_file "#{style_name}/views/kaminari/_next_page.html.erb", "app/views/layouts/kaminari/_next_page.html.erb"
      copy_file "#{style_name}/views/kaminari/_page.html.erb", "app/views/layouts/kaminari/_page.html.erb"
      copy_file "#{style_name}/views/kaminari/_paginator.html.erb", "app/views/layouts/kaminari/_paginator.html.erb"
      copy_file "#{style_name}/views/kaminari/_prev_page.html.erb", "app/views/layouts/kaminari/_prev_page.html.erb"

      copy_file "#{style_name}/images/kaminari/ergo_nav.png", "app/assets/images/styles/#{style_name}/kaminari/ergo_nav.png"
    end

    directory "#{style_name}/images/style", "app/assets/images/styles/#{style_name}"

    #if options.scaffolding?
    #  directory "scaffold", "lib/templates"
    #end

    application do
      <<-FILE.gsub(/^      /, '')
        config.generators do |g|
            g.stylesheets         false
            g.javascripts         false
            g.ergosca_controller :ergosca_controller
          end
      FILE
    end
  end

  private
  def style_name
    style.underscore
  end

  def app_name
    File.basename(Dir.pwd)
  end
end
