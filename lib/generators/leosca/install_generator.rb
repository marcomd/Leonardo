module Leosca
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../', __FILE__)
      class_option :erb, :type => :boolean, :default => true, :description => "Copy erb files"

      def copy_templates_to_local
        directory "erb/leosca", "lib/generators/erb/leosca" if options.erb?
        directory "rails/leosca", "lib/generators/rails/leosca"
        directory "rails/leosca_controller", "lib/generators/rails/leosca_controller"
        copy_file "leonardo.rb", "lib/generators/leonardo.rb"
      end
    end
  end
end

