require 'spec_helper'

<%
def value_for_check(attribute)
  case attribute.type
  when :references, :belongs_to
    "have_content(@#{ns_file_name}.#{attribute.name}.try(:name) || @#{ns_file_name}.#{attribute.name}.try(:id))"
  when :boolean
    "have_css(\"img.\#{@#{ns_file_name}.#{attribute.name} ? \"ico_true\" : \"ico_false\"}\")"
  else
    "have_content(@#{ns_file_name}.#{attribute.name})"
  end
end
%>

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= ns_table_name %>/show.html.<%= options[:template_engine] %>" do
  before(:each) do
    @<%= ns_file_name %> = assign(:<%= ns_file_name %>, Factory(:<%= ns_file_name %>) )
    <%- base_parent_resources.each do |parent| -%>
    @<%= parent %> = assign(:<%= parent %>, @<%= ns_file_name %>.<%= parent %>)
    <%- end -%>
  end

  it "renders attributes" do
    render
<% for attribute in output_attributes -%>
    rendered.should <%= value_for_check(attribute) %>
<% end -%>
  end
end
