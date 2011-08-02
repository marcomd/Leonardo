module Ergosca
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../', __FILE__)
      class_option :erb, :type => :boolean, :default => true, :description => "Copy erb files"

      def copy_templates_to_local
        directory "erb/ergosca", "lib/generators/erb/ergosca" if options.erb?
        directory "rails/ergosca", "lib/generators/rails/ergosca"
        directory "rails/ergosca_controller", "lib/generators/rails/ergosca_controller"
      end
    end
  end
end

