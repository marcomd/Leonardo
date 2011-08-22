class LeolayGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :style, :type => :string, :default => "cloudy"
  class_option :pagination, :type => :boolean, :default => true, :description => "Include pagination files"
  class_option :main_color, :type => :string, :default => nil, :description => "Force a main color for the stylesheet"
  class_option :second_color, :type => :string, :default => nil, :description => "Force a secondary color for the stylesheet"
  class_option :authentication, :type => :boolean, :default => true, :description => "Add code to manage authentication with devise"
  class_option :authorization, :type => :boolean, :default => true, :description => "Add code to manage authorization with cancan"
  class_option :user_class, :type => :boolean, :default => 'user', :description => "Set the user class name"
  class_option :formtastic, :type => :boolean, :default => true, :description => "Copy formtastic files into leosca custom folder (inside project)"


  def generate_layout
    template "config.rb", "config/initializers/config.rb"

    template "styles/#{style_name}/stylesheet.sass",
             "app/assets/stylesheets/#{style_name}.sass"

    copy_file "layout_helper.rb", "app/helpers/layout_helper.rb"

    copy_file "styles/#{style_name}/views/layout/application.html.erb", "app/views/layouts/application.html.erb", :force => true
    template "styles/#{style_name}/views/layout/_layout.html.erb", "app/views/layouts/_#{style_name}.html.erb"
              #{:authentication => options.authentication?,
              #:authorization => options.authorization?}
    copy_file "styles/#{style_name}/views/layout/_message.html.erb", "app/views/application/_message.html.erb"
    copy_file "styles/#{style_name}/views/layout/_session.html.erb", "app/views/application/_session.html.erb" if options.authentication?

    copy_file "config/locales/en.yml", "config/locales/en.yml"
    copy_file "config/locales/it.yml", "config/locales/it.yml"

    copy_file "lib/utility.rb", "lib/extras/utility.rb"

    if options.pagination?
      copy_file "config/locales/kaminari.en.yml", "config/locales/kaminari.en.yml"
      copy_file "config/locales/kaminari.it.yml", "config/locales/kaminari.it.yml"

      copy_file "styles/#{style_name}/views/kaminari/_next_page.html.erb", "app/views/kaminari/_next_page.html.erb"
      copy_file "styles/#{style_name}/views/kaminari/_page.html.erb", "app/views/kaminari/_page.html.erb"
      copy_file "styles/#{style_name}/views/kaminari/_paginator.html.erb", "app/views/kaminari/_paginator.html.erb"
      copy_file "styles/#{style_name}/views/kaminari/_prev_page.html.erb", "app/views/kaminari/_prev_page.html.erb"

      copy_file "styles/#{style_name}/images/kaminari/nav.png", "app/assets/images/styles/#{style_name}/kaminari/nav.png"
    end

    directory "styles/#{style_name}/images/style", "app/assets/images/styles/#{style_name}"

    if options.authentication?
      copy_file "config/locales/devise.en.yml", "config/locales/devise.en.yml"
      copy_file "config/locales/devise.it.yml", "config/locales/devise.it.yml"
      directory "app/views/devise", "app/views/devise"
    end
  end

  def setup_application
    application do
      <<-FILE.gsub(/^      /, '')
        config.generators do |g|
            g.stylesheets         false
            g.javascripts         false
            g.leosca_controller :leosca_controller
          end

          config.autoload_paths += %W(\#{config.root}/lib/extras)
      FILE
    end

    file = "app/controllers/application_controller.rb"
    if File.exists?(file)
      inject_into_class file, ApplicationController do
        <<-FILE.gsub(/^      /, '')
        rescue_from CanCan::AccessDenied do |exception|
          redirect_to root_url, :alert => exception.message
        end
        FILE
      end if options.authorization?

      #{options.authentication? ? ", :authenticate_user!" : ""}
      inject_into_class file, ApplicationController do
        <<-FILE.gsub(/^      /, '')
        before_filter :localizate

        def localizate
          if params[:lang]
            session[:lang] = params[:lang]
          else
            session[:lang] ||= I18n.default_locale
          end
          I18n.locale = session[:lang]
        end
        FILE
      end
    end
  end

  def setup_authentication
    file = "app/models/#{options.user_class}.rb"
    #puts "File #{file} #{File.exists?(file) ? "" : "does not"} exists!"
    return unless options.authentication? and File.exists?(file)

    inject_into_class file, User do
      <<-FILE.gsub(/^    /, '')
      ROLES = %w[admin manager user guest]
      scope :with_role, lambda { |role| {:conditions => "roles_mask & \#{2**ROLES.index(role.to_s)} > 0 "} }

      def roles=(roles)
        self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
      end
      def roles
        ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
      end
      def role_symbols
        roles.map(&:to_sym)
      end
      def role?(role)
        roles.include? role.to_s
      end
      FILE
    end

  end

  def setup_authorization
    file = "app/models/ability.rb"
    return unless File.exists?(file)
    inject_into_file file, :before => "  end\nend" do
      <<-FILE.gsub(/^      /, '')
          user ||= User.new
          can :manage, :all if user.role? :admin

      FILE
    end
  end


  def create_admin_migration
    file = "db/migrate/*_create_admin.rb"
    return unless options.authentication? and Dir[file].empty?
    file = file.sub('*', Time.now.strftime("%Y%m%d%H9999"))
    create_file file do
      <<-FILE.gsub(/^      /, '')
      class CreateAdmin < ActiveRecord::Migration
        def self.up
          add_column :users, :roles_mask, :integer
          user=User.new :email => 'admin@#{app_name}.com', :password => '#{app_name}', :password_confirmation => '#{app_name}'
          user.roles=['admin']
          user.save
          user=User.new :email => 'manager@#{app_name}.com', :password => '#{app_name}', :password_confirmation => '#{app_name}'
          user.roles=['manager']
          user.save
          user=User.new :email => 'user@#{app_name}.com', :password => '#{app_name}', :password_confirmation => '#{app_name}'
          user.roles=['user']
          user.save
        end
        def self.down
          User.delete User.find_all_by_email(['admin@#{app_name.downcase}.com',
                                              'manager@#{app_name.downcase}.com',
                                              'user@#{app_name.downcase}.com']).map(&:id)
          remove_column :users, :roles_mask
        end
      end
      FILE
    end
  end

  def setup_formtastic
    return unless options.formtastic?

    file = "app/assets/stylesheets/formtastic.css"
    copy_file file, file
    file = "app/assets/stylesheets/formtastic_changes.css"
    copy_file file, file

    #New version include custom partial _form
    #file_source = "lib/templates/erb/scaffold/_form.html.erb"
    #file_destination = "lib/templates/erb/leosca/_form.html.erb"
    #copy_file file_source, file_destination if File.exists?(file_source) and not File.exists?(file_destination)

    file = "config/initializers/formtastic.rb"
    inject_into_file file, :after => "# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false" do
      <<-FILE.gsub(/^      /, '')

      Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
      FILE
    end if File.exists?(file)
  end

  private
  def style_name
    style.underscore
  end

  def app_name
    File.basename(Dir.pwd)
  end
end
