require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= ns_table_name %>/edit.html.<%= options[:template_engine] %>" do
  before(:each) do
    @<%= ns_file_name %> = assign(:<%= ns_file_name %>, Factory(:<%= ns_file_name %>) )
    <%- base_parent_resources.each do |parent| -%>
    @<%= parent %> = assign(:<%= parent %>, @<%= ns_file_name %>.<%= parent %> )
    <%- end -%>
  end

  it "renders the edit <%= ns_file_name %> form" do
    render

    rendered.should have_selector("form", :action => <%= underscore_resource_path :parent_singular_resource_plural %>_path(<%= formatted_resource_path "@", "@" %>), :method => "post") do |form|
    <% for attribute in output_attributes -%>
  form.should have_selector("<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>", :name => "<%= ns_file_name %>[<%= attribute.name %>]")
    <% end -%>
end
  end
end
