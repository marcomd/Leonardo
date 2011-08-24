require 'rails/generators/erb'
require 'rails/generators/resource_helpers'

module Erb
  module Generators
    class LeoscaGenerator < Base
      include Rails::Generators::ResourceHelpers
      #puts 'erb:leosca'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :authorization, :type => :boolean, :default => true, :description => "Add code to manage authorization with cancan"
      class_option :remote, :type => :boolean, :default => true, :description => "Enable ajax. You can also do later set remote to true into index view."
      class_option :formtastic, :type => :boolean, :default => true, :description => "Create forms to manage with formtastic gem"

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

    protected

      def available_views
        %w(index edit show new _form _list destroy)
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

      def authorization?
        File.exists? "app/models/ability.rb"
      end
      def formtastic?
        return false unless options.formtastic?
        File.exists? "config/initializers/formtastic.rb"
      end
      def jquery_ui?
        File.exists? "vendor/assets/javascripts/jquery-ui"
      end
    end
  end
end
