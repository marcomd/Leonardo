require 'generators/rspec/integration/integration_generator'
require 'generators/leonardo' #leonardo base

module Rspec
  module Generators
    class LeointegrationGenerator < ::Rspec::Generators::IntegrationGenerator
      include ::Leonardo::Leosca
      include ::Leonardo::Nested
      include ::Leonardo::Nested::Test

      #puts 'Rspec:Generators:LeointegrationGenerator'
      source_paths << File.expand_path('../templates', __FILE__)

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      class_option :remote, :type => :boolean, :default => true, :desc => "It checks ajax sections"
      class_option :under, :type => :string, :default => "", :banner => "brand/category", :desc => "Nested resources"
      class_option :leospace, :type => :string, :default => "", :banner => ":admin", :desc => "To nest a resource under namespace(s)"

      def generate_request_spec
        return unless options[:request_specs]

        template 'request_spec.rb',
                 File.join('spec/requests', class_path, base_namespaces, "#{table_name}_spec.rb")
      end

    end
  end
end
