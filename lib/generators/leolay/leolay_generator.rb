class LeolayGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :style, :type => :string, :default => "cloudy"
  class_option :pagination, :type => :boolean, :default => true, :desc => "Include pagination files"
  class_option :main_color, :type => :string, :default => nil, :desc => "Force a main color for the stylesheet"
  class_option :second_color, :type => :string, :default => nil, :desc => "Force a secondary color for the stylesheet"
  class_option :authentication, :type => :boolean, :default => true, :desc => "Add code to manage authentication with devise"
  class_option :authorization, :type => :boolean, :default => true, :desc => "Add code to manage authorization with cancan"
  class_option :auth_class, :type => :boolean, :default => 'user', :desc => "Set the authentication class name"
  class_option :formtastic, :type => :boolean, :default => true, :desc => "Copy formtastic files into leosca custom folder (inside project)"
  class_option :jquery_ui, :type => :boolean, :default => true, :desc => "To use jQuery ui improvement"
  class_option :rspec, :type => :boolean, :default => true, :desc => "Include custom rspec generator and custom templates"

  def generate_layout
    template "config.rb", "config/initializers/config.rb"

    template "styles/#{style_name}/stylesheets/app/stylesheet.sass", "app/assets/stylesheets/#{style_name}.sass"

    copy_file "layout_helper.rb", "app/helpers/layout_helper.rb"

    copy_file "styles/#{style_name}/views/layout/application.html.erb", "app/views/layouts/application.html.erb", :force => true
    template "styles/#{style_name}/views/layout/_layout.html.erb", "app/views/layouts/_#{style_name}.html.erb"
    copy_file "styles/#{style_name}/views/layout/_message.html.erb", "app/views/application/_message.html.erb"
    copy_file "styles/#{style_name}/views/layout/_session.html.erb", "app/views/application/_session.html.erb" if options.authentication?

    locale_path = "config/locales"
    source_paths.each do |source_path|
      files = Dir["#{source_path}/#{locale_path}/??.yml"]
      files.each do |f|
        copy_file f, "#{locale_path}/#{File.basename(f)}"
      end
      break if files.any?
    end

    copy_file "lib/utility.rb", "lib/extras/utility.rb"

    if options.pagination?
      source_paths.each do |source_path|
        files = Dir["#{source_path}/#{locale_path}/kaminari.??.yml"]
        files.each do |f|
          copy_file f, "#{locale_path}/#{File.basename(f)}"
        end
        break if files.any?
      end

      #copy_file "styles/#{style_name}/views/kaminari/_next_page.html.erb", "app/views/kaminari/_next_page.html.erb"
      #copy_file "styles/#{style_name}/views/kaminari/_page.html.erb", "app/views/kaminari/_page.html.erb"
      #copy_file "styles/#{style_name}/views/kaminari/_paginator.html.erb", "app/views/kaminari/_paginator.html.erb"
      #copy_file "styles/#{style_name}/views/kaminari/_prev_page.html.erb", "app/views/kaminari/_prev_page.html.erb"
      directory "styles/#{style_name}/views/kaminari", "app/views/kaminari"


      #copy_file "styles/#{style_name}/images/kaminari/nav.png", "app/assets/images/styles/#{style_name}/kaminari/nav.png"
      directory "styles/#{style_name}/images/kaminari", "app/assets/images/styles/#{style_name}/kaminari"
    end

    directory "styles/#{style_name}/images/style", "app/assets/images/styles/#{style_name}"

    directory "styles/#{style_name}/images/jquery-ui", "app/assets/images/styles/#{style_name}/jquery-ui" if options.jquery_ui?

    if options.authentication?
      source_paths.each do |source_path|
        files = Dir["#{source_path}/#{locale_path}/devise.??.yml"]
        files.each do |f|
          copy_file f, "#{locale_path}/#{File.basename(f)}"
        end
        break if files.any?
      end
      directory "app/views/devise", "app/views/devise"
    end
  end

  def setup_application
    application do
      <<-FILE.gsub(/^      /, '')
        config.generators do |g|
            g.stylesheets         false
            g.javascripts         false
            g.leosca_controller   :leosca_controller
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
    file = "app/models/#{options.auth_class}.rb"
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
      def admin?
        self.role? 'admin'
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
    file = file.sub('*', Time.now.strftime("%Y%m%d%H%M99"))
    create_file file do
      <<-FILE.gsub(/^      /, '')
      class CreateAdmin < ActiveRecord::Migration
        def self.up
          add_column :users, :roles_mask, :integer
          user=User.new :email => 'admin@#{app_name}.com', :password => 'abcd1234', :password_confirmation => 'abcd1234'
          user.roles=['admin']
          user.save
          user=User.new :email => 'manager@#{app_name}.com', :password => 'abcd1234', :password_confirmation => 'abcd1234'
          user.roles=['manager']
          user.save
          user=User.new :email => 'user@#{app_name}.com', :password => 'abcd1234', :password_confirmation => 'abcd1234'
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

    path = "styles/#{style_name}/stylesheets/vendor/formtastic"
    dest_path = "vendor/assets/stylesheets/formtastic"

    path = dest_path unless File.exists?(path)

    file = "#{path}/formtastic.css"
    copy_file file, file unless File.exists?(file)
    file = "#{path}/formtastic_changes.css"
    copy_file file, file

    file = "config/initializers/formtastic.rb"
    inject_into_file file, :after => "# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false" do
      <<-FILE.gsub(/^      /, '')

      Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
      FILE
    end if File.exists?(file)
  end

  def setup_javascript
    app_path = "app/assets/javascripts"
    vendor_path = "vendor/assets/javascripts"

    file = "#{app_path}/custom.js"
    copy_file file, file

    file = "#{vendor_path}/vendor.js"
    copy_file file, file

    file = "#{app_path}/application.js"
    append_file file do
      <<-FILE.gsub(/^      /, '')

      //= require vendor
      FILE
    end

    if options.jquery_ui?
      file = "#{app_path}/custom.js"
      append_file file do
        <<-FILE.gsub(/^        /, '')

        $(function (){
          $('.calendar').datepicker();
        });
        FILE
      end

      file = "#{app_path}/application.js"
      inject_into_file file, :after => "//= require jquery_ujs" do
        <<-FILE.gsub(/^        /, '')

        //= require jquery-ui
        FILE
      end

      #files = Dir["#{vendor_path}/jquery-ui/jquery.ui.datepicker-??.js"]
      #files.each do |f|
      #  copy_file f, f
      #end
      directory "#{vendor_path}/jquery-ui", "#{vendor_path}/jquery-ui"

      file = "#{vendor_path}/vendor.js"
      append_file file do
        <<-FILE.gsub(/^        /, '')

        //= require_tree ./jquery-ui
        FILE
      end

    end
  end

  def setup_stylesheets
    app_path = "app/assets/stylesheets"
    vendor_path = "vendor/assets/stylesheets"

    file = "#{vendor_path}/vendor.css"
    copy_file file, file

    if options.jquery_ui?
      directory "styles/#{style_name}/stylesheets/vendor/jquery-ui", "vendor/assets/stylesheets/jquery-ui"

      file = "#{app_path}/application.css"
      inject_into_file file, :before => "*/" do
        <<-FILE.gsub(/^        /, '')
         *= require vendor
        FILE
      end

      file = "#{vendor_path}/vendor.css"
      inject_into_file file, :before => "*/" do
        <<-FILE.gsub(/^        /, '')
         *= require_tree ./jquery-ui
        FILE
      end
    end

    file = "#{vendor_path}/vendor.css"
    inject_into_file file, :before => "*/" do
      <<-FILE.gsub(/^      /, '')
       *= require_tree ./formtastic
      FILE
    end if options.formtastic?
  end

  def setup_rspec
    file = "spec/spec_helper.rb"
    return unless File.exists?(file) && options.rspec?
    inject_into_file file, :after => "require 'rspec/rails'" do
    <<-FILE.gsub(/^    /, '')

    require 'capybara/rspec'
    require 'helpers/application_helpers_spec'

    Capybara.default_wait_time = 10 #default=2
    FILE
    end

    gsub_file file, 'config.fixture_path = "#{::Rails.root}/spec/fixtures"', '#config.fixture_path =  "#{::Rails.root}/spec/fixtures"'
    #inject_into_file file, "#", :before => 'config.fixture_path = "#{::Rails.root}/spec/fixtures"'

    gsub_file file, "config.use_transactional_fixtures = true" do
    <<-FILE.gsub(/^  /, '')
  config.use_transactional_fixtures = false

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.include ApplicationHelpers
    FILE
    end

    file = "spec/factories.rb"
    copy_file file, file
    file = "spec/support/devise.rb"
    copy_file file, file
    file = "spec/helpers/application_helpers_spec.rb"
    copy_file file, file
    #file = "lib/templates/rspec/scaffold"
    #directory file, file
    #file = "lib/templates/rspec/scaffold"
    #directory file, file
    #file = "lib/generators/rspec/scaffold"
    #directory file, file

  end

  private
  def style_name
    style.underscore
  end

  def app_name
    File.basename(Dir.pwd)
  end

end
