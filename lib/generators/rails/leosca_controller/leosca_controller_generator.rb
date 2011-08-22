require 'rails/generators/resource_helpers'

WINDOWS = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)
CRLF = WINDOWS ? "\r\n" : "\n"

module Rails
  module Generators
    class LeoscaControllerGenerator < NamedBase
      include ResourceHelpers
      #puts 'rails:leosca_controller'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :seeds, :type => :boolean, :default => true, :description => "Create seeds to run with rake db:seed"
      class_option :seeds_elements, :type => :string, :default => "30", :description => "Choose seeds elements", :banner => "NUMBER OF ARRAY ELEMENTS"
      class_option :remote, :type => :boolean, :default => true, :description => "Enable ajax. You can also do later set remote to true into index view."
      #class_option :authentication, :type => :boolean, :default => true, :description => "Add code to manage authentication with devise"
      #class_option :authorization, :type => :boolean, :default => true, :description => "Add code to manage authorization with cancan"

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
              content << "        #{attribute.name}: \"#{attribute.name.capitalize}\"#{CRLF}"
            end
            content << "        op_new: \"New #{singular_table_name}\"#{CRLF}"
            content << "        op_edit: \"Editing #{singular_table_name}\"#{CRLF}"
            content << "        op_index: \"Listing #{plural_table_name}\"#{CRLF}"
            content
          end

          #Model name
          inject_into_file file, :after => "models: &models#{CRLF}" do
            <<-FILE.gsub(/^    /, '')
            #{file_name}: "#{file_name.capitalize}"
            #{controller_name}: "#{controller_name.capitalize}"
            FILE
          end

          #Formtastic
          inject_into_file file, :after => "    hints:#{CRLF}" do
            content = "      #{file_name}:#{CRLF}"
            attributes.each do |attribute|
              case attribute.type
              when :integer, :decimal, :float
                content << "        #{attribute.name}: \"Insert #{attribute.name} as #{attribute.type.to_s} number\"#{CRLF}"
              when :boolean
                content << "        #{attribute.name}: \"Select if #{attribute.name} or not\"#{CRLF}"
              else
                content << "        #{attribute.name}: \"Choose a good #{attribute.name} for this #{file_name}\"#{CRLF}"
              end
            end
            content
          end

        end
      end

      def update_layout_html
        file = "app/views/layouts/_#{CONFIG[:default_style]}.html.erb"
        inject_into_file file, :after => "<!-- Insert below other elements -->#{CRLF}" do
          <<-FILE.gsub(/^          /, '')
                      #{"<% if can? :read, #{class_name} -%>" if authorization?}
                      <li class="<%= controller.controller_path == '#{controller_name}' ? 'active' : '' %>"><a href="<%= #{controller_name}_path %>"><%= t('models.#{controller_name}') %></a></li>
                      #{"<% end -%>" if authorization?}
          FILE
        end if File.exists?(file)
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
            value = case attribute.type
              when :boolean         then :true
              when :integer         then "#"
              when :float, :decimal then "#.46"
              else                       "'#{attribute.name.capitalize}\#'"
            end
            items << " :#{attribute.name} => #{value}"
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

      protected
      def authorization?
        File.exists? "app/models/ability.rb"
      end
      def authentication?
        file = "app/models/user.rb"
        File.exists?(file)
        #get file do |content|
        #  content.include? "devise"
        #end
      end

    end
  end
end
