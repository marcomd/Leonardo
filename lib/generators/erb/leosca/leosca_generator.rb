require 'rails/generators/erb'
require 'rails/generators/resource_helpers'
require File.join(File.dirname(__FILE__), '../../base')

module Erb
  module Generators
    class LeoscaGenerator < Base
      include Rails::Generators::ResourceHelpers
      include ::Leonardo::Leosca
      include ::Leonardo::Nested
      #puts 'erb:leosca'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :authorization, :type => :boolean, :default => true, :description => "Add code to manage authorization with cancan"
      class_option :remote, :type => :boolean, :default => true, :description => "Enable ajax. You can also do later set remote to true into index view."
      class_option :formtastic, :type => :boolean, :default => true, :description => "Create forms to manage with formtastic gem"
      class_option :under, :type => :string, :default => "", :banner => "brand/category"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          filenames = filenames_all_formats(view, source_paths)
          filenames.each do |filename|
            #Looking for custom filename into subfolder
            filename_source = "#{"formtastic/" if formtastic?}#{filename}"
            search_into_subfolder = nil
            source_paths.each do |path|
              if File.exists?(File.join(path,filename_source))
                search_into_subfolder = true
                break
              end
            end
            filename_source = filename unless search_into_subfolder

            template filename_source, File.join("app/views", controller_file_path, filename)
          end
        end
      end

      def update_layout_html
        file = "app/views/layouts/_#{CONFIG[:default_style]}.html.erb"
        if nested?
          inject_into_file file, :after => "<!-- Insert below here other #{last_parent} elements -->#{CRLF}" do
            <<-FILE.gsub(/^            /, '')
                          #{"<% if can?(:read, #{class_name}) && controller.controller_path == '#{controller_name}' -%>" if authorization?}
                          <li class="active"><%= t('models.#{plural_table_name}') %></li>
                          <!-- Insert below here other #{singular_table_name} elements -->
                          #{"<% end -%>" if authorization?}
            FILE
          end if File.exists?(file)
        else
          inject_into_file file, :after => "<!-- Insert below other elements -->#{CRLF}" do
            <<-FILE.gsub(/^            /, '')
                        #{"<% if can?(:read, #{class_name}) -%>" if authorization?}
                        <li class="<%= controller.controller_path == '#{controller_name}' ? 'active' : '' %>"><a href="<%= #{plural_table_name}_path %>"><%= t('models.#{plural_table_name}') %></a></li>
                        <!-- Insert below here other #{singular_table_name} elements -->
                        #{"<% end -%>" if authorization?}
            FILE
          end if File.exists?(file)
        end
      end

      def update_parent_views
        return unless nested?
        file = "app/views/#{plural_last_parent}/_list.erb"
        inject_into_file file, :before => "<!-- Manage section, do not remove this tag -->" do
          <<-FILE.gsub(/^          /, '')
              <td><%= link_to t('models.#{plural_table_name}'), #{underscore_resource_path :parent_singular_resource_plural}_path(#{last_parent}) %></td>

          FILE
        end if File.exists?(file)
      end

    protected

      def available_views
        %w(index edit show new _form _list destroy _show)
      end

      def filenames_all_formats(name, paths=[], formats=[:html, :js, nil])
        filenames = []
        paths.each do |path|
          formats.each do |format|
            filename = filename_with_extensions(format, name)
            if File.exists?(File.join(path, filename))
              filenames << filename
            end
          end
          break if filenames.any?
        end
        filenames
      end
      def filename_with_extensions(format, name, parser=:erb)
        [name, format, parser].compact.join(".")
      end

    end
  end
end
