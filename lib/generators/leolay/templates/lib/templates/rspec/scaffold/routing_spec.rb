require "spec_helper"

describe <%= controller_class_name %>Controller do
  describe "routing" do

<% unless options[:singleton] -%>
    it "routes to #index" do
      get("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>").should route_to("<%= ns_table_name %>#index"<%= nested_params_http_request("1") %>)
    end

<% end -%>
    it "routes to #new" do
      get("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>/new").should route_to("<%= ns_table_name %>#new"<%= nested_params_http_request("1") %>)
    end

    it "routes to #show" do
      get("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>/1").should route_to("<%= ns_table_name %>#show", :id => "1"<%= nested_params_http_request("1") %>)
    end

    it "routes to #edit" do
      get("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>/1/edit").should route_to("<%= ns_table_name %>#edit", :id => "1"<%= nested_params_http_request("1") %>)
    end

    it "routes to #create" do
      post("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>").should route_to("<%= ns_table_name %>#create"<%= nested_params_http_request("1") %>)
    end

    it "routes to #update" do
      put("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>/1").should route_to("<%= ns_table_name %>#update", :id => "1"<%= nested_params_http_request("1") %>)
    end

    it "routes to #destroy" do
      delete("/<%= plural_parent_resources.join('/1/') %><%= "/1/" if nested? %><%= ns_table_name %>/1").should route_to("<%= ns_table_name %>#destroy", :id => "1"<%= nested_params_http_request("1") %>)
    end

  end
end
