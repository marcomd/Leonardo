require 'rails/generators/rails/resource/resource_generator'
require File.join(File.dirname(__FILE__), '../../base')

module Rails
  module Generators
    class LeoscaGenerator < ResourceGenerator #metagenerator
      include ::Leonardo::Nested
      #puts 'rails:leosca'

      remove_hook_for :resource_controller
      remove_class_option :actions

      class_option :stylesheets, :type => :boolean, :default => false, :desc => "Generate Stylesheets"
      class_option :stylesheet_engine, :desc => "Engine for Stylesheets"
      class_option :under, :type => :string, :default => "", :banner => "brand/category", :desc => "Choose namespace(s) if resource must be nested"

      hook_for :leosca_controller, :required => true

      hook_for :assets do |assets|
        invoke assets, [controller_name]
      end

      hook_for :stylesheet_engine do |stylesheet_engine|
        invoke stylesheet_engine, [controller_name] if options[:stylesheets] && behavior == :invoke
      end

      #Override resource def
      def add_resource_route
        return if options[:actions].present?

        if options[:under].present?
          route_resources = plural_parent_resources
          route_map = "resources"
        else
          route_resources = regular_class_path
          route_map = "namespace"
        end

        route_config =  route_resources.collect{|m| "#{route_map} :#{m} do " }.join(" ")
        route_config << "resources :#{file_name.pluralize}"
        route_config << " end" * route_resources.size
        route route_config
      end

    end
  end
end