#require 'thor/group'
require 'rails/generators/resource_helpers'

WINDOWS = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)
CRLF = WINDOWS ? "\r\n" : "\n"

module Rails
  module Generators
    class ErgoscaControllerGenerator < NamedBase
      include ResourceHelpers
      #include Thor::Actions
      
      puts 'rails:ergosca_controller'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      check_class_collision :suffix => "Controller"

      class_option :orm, :banner => "NAME", :type => :string, :required => true,
                         :desc => "ORM to generate the controller for"

      def create_controller_files
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      hook_for :template_engine, :as => :ergosca
      hook_for :test_framework, :as => :scaffold

      # Invoke the helper using the controller name (pluralized)
      hook_for :helper, :as => :scaffold do |invoked|
        invoke invoked, [ controller_name ]
      end

      def update_yaml
        #Inject model and attributes name into yaml files for i18n
        path = "config/locales"
        files = []
        files = Dir["#{path}/??.yml"]
        puts files.join(', ')
        puts Dir.getwd
        files.each do |file|

          #Fields name
          inject_into_file file, :after => "#Attributes zone - do not remove#{CRLF}" do
            content = "      #{file_name}:#{CRLF}"
            attributes.each do |attribute|
              content << "        #{attribute.name}: \"#{attribute.name.capitalize}\"#{CRLF}"
            end
            content << "        op_new: \"New #{controller_name}\"#{CRLF}"
            content << "        op_edit: \"Editing #{controller_name}\"#{CRLF}"
            content << "        op_index: \"Listing #{controller_name}\"#{CRLF}"
            content
          end if File.exists?(file)

          #Model name
          inject_into_file file, :after => "models: &models#{CRLF}" do
            <<-FILE.gsub(/^    /, '')
            #{file_name}: "#{file_name.capitalize}"
            #{controller_name}: "#{controller_name.capitalize}"
            FILE
          end if File.exists?(file)

        end
      end

      def update_layout
        file = "app/views/layouts/_#{CONFIG[:default_style]}.html.erb"
        inject_into_file file, :after => "<!-- Insert below other elements -->#{CRLF}" do
          <<-FILE.gsub(/^          /, '')
                      <li class="<%= controller.controller_path == '#{controller_name}' ? 'active' : '' %>"><a href="<%= #{controller_name}_path %>"><%= t('models.#{controller_name}') %></a></li>
          FILE
        end if File.exists?(file)
      end

    end
  end
end
