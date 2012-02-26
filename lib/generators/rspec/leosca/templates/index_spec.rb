require 'spec_helper'

<%
def value_for_check(attribute)
  name = ":text"
  ([] <<
  case attribute.type
  when :boolean
    "\"tr#tr\#{r.id}>td>img.\#{r.#{attribute.name} ? \"ico_true\" : \"ico_false\"}\""
  else
    "\"tr#tr\#{r.id}>td\""
  end <<
  case attribute.type
  when :references, :belongs_to
    "#{name} => (r.#{attribute.name}.try(:name) || r.#{attribute.name}.try(:id))"
  when :boolean
    nil
  when :decimal
    "#{name} => number_to_currency(r.#{attribute.name})"
  when :integer
    "#{name} => number_with_delimiter(r.#{attribute.name})"
  when :float
    "#{name} => number_with_precision(r.#{attribute.name})"
  else
    "#{name} => r.#{attribute.name}"
  end
  ).compact.join(', ')
end
%>

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= formatted_namespace_path %><%= ns_table_name %>/index.html.<%= options[:template_engine] %>" do
  before(:each) do
    <%- parents = []; str_parents_create = str_parents_where = "" -%>
    <%- base_parent_resources.each do |parent| -%>
    @<%= parent %> = assign(:<%= parent %>, Factory(:<%= parent %>) )
    <%- parents << ":#{parent}_id => @#{parent}.id" -%>
    <%- end -%>
    <%- str_parents_create = ", #{parents.join(', ')}" if parents.any? -%>
    <%- str_parents_where = ".where(#{parents.join(', ')})" if parents.any? -%>
    <%- if pagination? -%>
    FactoryGirl.create_list(:<%= ns_file_name %>, 2<%= str_parents_create %>)
    @records = assign(:<%= table_name %>, <%= class_name %><%= str_parents_where %>.order(:id).page(1) )
    <%- else -%>
    @records = assign(:<%= table_name %>, FactoryGirl.create_list(:<%= ns_file_name %>, 2<%= str_parents_create %>) )
    <%- end -%>
    assign(:<%= ns_file_name %>, Factory.build(:<%= ns_file_name %>) )
    view.stub(:sort_column, :sort_direction)
  end

  it "renders a list of <%= ns_table_name %>" do
    render
    @records.each do |r|
    <% for attribute in output_attributes -%>
  assert_select <%= value_for_check(attribute) %>
    <% end -%>
end
  end
end