module Leolay
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../../', __FILE__)

      def copy_all_to_local
        #directory "leolay", "lib/generators/leolay"
        copy_file "leolay/leolay_generator.rb", "lib/generators/leolay/leolay_generator.rb"
        copy_file "leolay/USAGE", "lib/generators/leolay/USAGE"
        directory "leolay/templates", "lib/generators/leolay/templates"
      end
    end
  end
end

