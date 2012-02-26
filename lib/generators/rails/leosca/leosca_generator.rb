require 'rails/generators/rails/scaffold/scaffold_generator'
require File.join(File.dirname(__FILE__), '../../leonardo')

module Rails
  module Generators
    class LeoscaGenerator < ::Rails::Generators::ScaffoldGenerator
      include ::Leonardo::Nested
      #puts 'rails:leosca'

      class_option :under, :type => :string, :default => "", :banner => "brand/category", :desc => "To nest a resource under another(s)"
      class_option :leospace, :type => :string, :default => "", :banner => ":admin", :desc => "To nest a resource under namespace(s)"

      remove_hook_for :scaffold_controller
      hook_for :leosca_controller, :required => true

      #Override
      def add_resource_route
        return if options[:actions].present?

        route_config = ""
        route_config << plural_parent_resources.map{|m| "resources :#{m} do " }.join(" ") if nested?
        route_config << base_namespaces.map{|m| "namespace :#{m} do " }.join(" ") if leospaced?
        route_config << regular_class_path.map{|m| "namespace :#{m} do " }.join(" ")
        route_config << <<-FILE.gsub(/^          /, '')
          resources :#{file_name.pluralize} do
              post :select,           :on => :collection
              post :edit_multiple,    :on => :collection
              put  :update_multiple,  :on => :collection
              put  :create_multiple,  :on => :collection
            end
        FILE
        route_config << " end" * (regular_class_path.size + plural_parent_resources.size + base_namespaces.size)
        route route_config
      end

    end
  end
end