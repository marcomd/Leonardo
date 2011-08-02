require 'rails/generators/erb'
require 'rails/generators/resource_helpers'

module Erb
  module Generators
    class ErgoscaGenerator < Base
      include Rails::Generators::ResourceHelpers

      puts 'erb:ergosca'

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          filenames = filenames_all_formats(view, source_paths)
          filenames.each do |filename|
            template filename, File.join("app/views", controller_file_path, filename)
          end
        end
      end

    protected

      def available_views
        %w(index edit show new _form _list)
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
      def filename_with_extensions(format, name)
        [name, format, :erb].compact.join(".")
      end

    end
  end
end
