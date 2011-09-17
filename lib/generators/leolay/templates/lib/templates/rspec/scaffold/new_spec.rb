require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= ns_table_name %>/new.html.<%= options[:template_engine] %>" do
  before(:each) do
    <%= "#{ns_file_name} = " if nested? %>assign(:<%= ns_file_name %>, Factory.build(:<%= ns_file_name %>) )
    <%- base_parent_resources.each do |parent| -%>
    @<%= parent %> = assign(:<%= parent %>, <%= ns_file_name %>.<%= parent %>)
    <%- end -%>
  end


  it "renders new <%= ns_file_name %> form" do
    render

    rendered.should have_selector("form", :action => <%= list_resources_path_test nil, "@" %>, :method => "post") do |form|
    <% for attribute in output_attributes -%>
  form.should have_selector("<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>", :name => "<%= ns_file_name %>[<%= attribute.name %>]")
    <% end -%>
end
  end
end
