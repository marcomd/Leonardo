require 'rails/generators/resource_helpers'
require File.join(File.dirname(__FILE__), '../../base')

WINDOWS = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)
CRLF = WINDOWS ? "\r\n" : "\n"

module Rails
  module Generators
    class LeoscaControllerGenerator < NamedBase
      include ResourceHelpers
      include ::Leonardo::Leosca
      include ::Leonardo::Nested
      include ::Leonardo::Nested::Test
      #puts 'rails:leosca_controller'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :seeds, :type => :boolean, :default => true, :desc => "Create seeds to run with rake db:seed"
      class_option :seeds_elements, :type => :string, :default => "30", :desc => "Choose seeds elements", :banner => "NUMBER"
      class_option :remote, :type => :boolean, :default => true, :desc => "Enable ajax. You can also do later set remote to true into index view."
      class_option :under, :type => :string, :default => "", :banner => "brand/category", :desc => "Nested resources"


      check_class_collision :suffix => "Controller"

      class_option :orm, :banner => "NAME", :type => :string, :required => true,
                         :desc => "ORM to generate the controller for"

      def create_controller_files
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      hook_for :template_engine, :as => :leosca
      hook_for :test_framework, :as => :scaffold

      # Invoke the helper using the controller name (pluralized)
      hook_for :helper, :as => :scaffold do |invoked|
        invoke invoked, [ controller_name ]
      end

      def update_yaml_locales
        #Inject model and attributes name into yaml files for i18n
        path = "config/locales"
        files = []
        files = Dir["#{path}/??.yml"]
        files.each do |file|

          next unless File.exists?(file)

          #Fields name
          inject_into_file file, :after => "#Attributes zone - do not remove#{CRLF}" do
            content = "      #{file_name}:#{CRLF}"
            attributes.each do |attribute|
              content << "        #{attribute.name}: \"#{attribute.name.humanize}\"#{CRLF}"
            end
            content << "        op_new: \"New #{singular_table_name}\"#{CRLF}"
            content << "        op_edit: \"Editing #{singular_table_name}\"#{CRLF}"
            if nested?
              content << "        op_index: \"Listing #{plural_table_name} belongings to %{parent} %{name}\"#{CRLF}"
            else
              content << "        op_index: \"Listing #{plural_table_name}\"#{CRLF}"
            end
            content
          end

          #Model name
          inject_into_file file, :after => "models: &models#{CRLF}" do
            <<-FILE.gsub(/^      /, '')
            #{file_name}: "#{file_name.capitalize}"
            #{controller_name}: "#{controller_name.capitalize}"
            FILE
          end

          #Formtastic
          inject_into_file file, :after => "    hints:#{CRLF}" do
            content = "      #{file_name}:#{CRLF}"
            attributes.each do |attribute|
              attr_name = attribute.name.humanize
              case attribute.type
              when :integer, :decimal, :float
                content << "        #{attribute.name}: \"Fill the #{attr_name} with a#{"n" if attribute.type == :integer} #{attribute.type.to_s} number\"#{CRLF}"
              when :boolean
                content << "        #{attribute.name}: \"Select if this #{file_name} should be #{attr_name} or not\"#{CRLF}"
              when :string, :text
                content << "        #{attribute.name}: \"Choose a good #{attr_name} for this #{file_name}\"#{CRLF}"
              when :date, :datetime, :time, :timestamp
                content << "        #{attribute.name}: \"Choose a #{attribute.type.to_s} for #{attr_name}\"#{CRLF}"
              else
                content << "        #{attribute.name}: \"Choose a #{attr_name}\"#{CRLF}"
              end
            end
            content
          end

        end
      end

      def update_ability_model
        file = "app/models/ability.rb"
        return unless File.exists?(file)
        inject_into_file file, :before => "  end\nend" do
          <<-FILE.gsub(/^      /, '')
          #can :read, #{class_name} if user.new_record? #Guest
          can :read, #{class_name} if user.role? :guest #Registered guest
          if user.role? :user
            can :read, #{class_name}
            can :update, #{class_name}
            can :create, #{class_name}
          end
          if user.role? :manager
            can :read, #{class_name}
            can :update, #{class_name}
            can :create, #{class_name}
            can :destroy, #{class_name}
          end

          FILE
        end
      end

      def add_seeds_db
        return unless options.seeds? and options[:seeds_elements].to_i > 0
        file = "db/seeds.rb"
        append_file file do
          items = []
          attributes.each do |attribute|
            items << attribute_to_hash(attribute)
          end
          row = "{ #{items.join(', ')} }"

          #TODO: to have different values for every row
          content = "#{CRLF}### Created by leosca controller generator ### #{CRLF}#{class_name}.create([#{CRLF}"
          options[:seeds_elements].to_i.times do |n|
            content << "#{row.gsub(/\#/, (n+1).to_s)},#{CRLF}"
          end
          content << "])#{CRLF}"
          content
        end if File.exists?(file)
      end

      def update_specs
        file = "spec/spec_helper.rb"
        return unless File.exists? file

        check_attr_to_have, check_attr_to_not_have = get_attr_to_match

        file = "spec/requests/#{plural_path_file_name}_spec.rb"
        remove = <<-FILE.gsub(/^      /, '')
          it "works! (now write some real specs)" do
            # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
            get #{plural_table_name}_path
            response.status.should be(200)
          end
        FILE
        gsub_file file, remove, ""

        inject_into_file file, :after => "describe \"GET /#{plural_table_name}\" do" do
        <<-FILE.gsub(/^      /, '')

          it "displays #{plural_table_name}" do
            #{singular_table_name} = Factory(:#{singular_table_name})
            visit #{list_resources_path_test}
            #{"login_view_as(:user_guest)" if authentication?}
            #save_and_open_page #uncomment to debug
            page.should #{check_attr_to_have}
            assert page.find("#tr\#{#{singular_table_name}.id}").visible?
          end
        FILE
        end

        inject_into_file file, :before => /^end/ do
          items = []
          attributes.each do |attribute|
            items << attribute_to_requests(attribute)
          end
          <<-FILE.gsub(/^        /, '')

          describe "POST /#{plural_table_name}" do
            it "creates a new #{singular_table_name}" do
              #{singular_table_name} = Factory.build(:#{singular_table_name})
              visit #{new_resource_path_test}
              #{"login_view_as(:user_admin)" if authentication?}
        #{items.join(CRLF)}
              click_button "Create \#{I18n.t('models.#{singular_table_name}')}"
              #save_and_open_page #uncomment to debug
              page.should have_content(I18n.t(:created, :model => I18n.t('models.#{singular_table_name}')))
              page.should #{check_attr_to_have}
            end
          end

          describe "Check ajax /#{plural_table_name}" do
            it "checks links on list page", :js => true do
              #{singular_table_name} = Factory(:#{singular_table_name})
              visit #{list_resources_path_test}
              #{"login_view_as(:user_manager)" if authentication?}            #authentication
              page.find("div#list").should #{check_attr_to_have}
              click_link I18n.t(:show)
              page.find("div.ui-dialog").should #{check_attr_to_have}         #checks if dialog is appeared
              click_link "close"                                              #close dialog
              !page.find("div.ui-dialog").visible?                            #checks if dialog has been closed
              click_link I18n.t(:destroy)                                     #check ajax destroy
              page.driver.browser.switch_to.alert.accept                      #confirms destroy
              #save_and_open_page                                             #uncomment to debug
              page.find("div#list").should #{check_attr_to_not_have}          #checks if content has been removed
              !page.find("#tr\#{#{singular_table_name}.id}").visible?         #checks if row has been hidden
            end
          end
          FILE
        end

        file = "spec/factories.rb"
        inject_into_file file, :before => "  ### Insert below here other your factories ###" do
          items = []
          attributes.each do |attribute|
            items << attribute_to_factories(attribute)
          end
          <<-FILE.gsub(/^        /, '')

          factory :#{singular_table_name} do |#{singular_table_name[0..0]}|
        #{items.join(CRLF)}
          end
          FILE
        end if File.exists?(file)

      end

    end
  end
end
