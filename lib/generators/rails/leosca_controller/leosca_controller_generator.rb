require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
require File.join(File.dirname(__FILE__), '../../leonardo')

WINDOWS = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)
CRLF = WINDOWS ? "\r\n" : "\n"

module Rails
  module Generators
    class LeoscaControllerGenerator < ::Rails::Generators::ScaffoldControllerGenerator
      include ::Leonardo::Leosca
      include ::Leonardo::Nested
      include ::Leonardo::Nested::Test
      #puts 'rails:leosca_controller'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :seeds, :type => :boolean, :default => true, :desc => "Create seeds to run with rake db:seed"
      class_option :seeds_elements, :type => :string, :default => "30", :desc => "Choose seeds elements", :banner => "NUMBER"
      class_option :remote, :type => :boolean, :default => true, :desc => "Enable ajax. You can also do later set remote to true into index view."
      class_option :under, :type => :string, :default => "", :banner => "brand/category", :desc => "To nest a resource under another(s)"
      class_option :leospace, :type => :string, :default => "", :banner => ":admin", :desc => "To nest a resource under namespace(s)"

      #Override
      def create_controller_files
        template 'controller.rb', File.join('app/controllers', class_path, base_namespaces, "#{controller_file_name}_controller.rb")
      end

      #Override
      hook_for :template_engine, :test_framework, :as => :leosca

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
