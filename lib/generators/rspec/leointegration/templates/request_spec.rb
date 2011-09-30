require 'spec_helper'
<%-
items = []
attributes.each do |attribute|
  items << "        #{attribute_to_requests(attribute)}"
end
check_attr_to_have, check_attr_to_not_have = get_attr_to_match
-%>

describe "<%= class_name.pluralize %>" do
  describe "GET /<%= table_name %>" do
    it "displays <%= plural_table_name %>" do
      <%= singular_table_name %> = Factory(:<%= singular_table_name %>)
      visit <%= list_resources_path_test %>
      <%= "login_view_as(:user_guest)" if authentication? -%>
      #save_and_open_page #uncomment to debug
      page.should <%= check_attr_to_have %>
      assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
    end

    describe "POST /<%= plural_table_name %>" do
      it "creates a new <%= singular_table_name %>" do
        <%= singular_table_name %> = Factory.build(:<%= singular_table_name %>)
        visit <%= new_resource_path_test %>
        <%= "login_view_as(:user_admin)" if authentication? %>
<%= items.join(CRLF) %>
        click_button "Create #{I18n.t('models.<%= singular_table_name %>')}"
        #save_and_open_page #uncomment to debug
        page.should have_content(I18n.t(:created, :model => I18n.t('models.<%= singular_table_name %>')))
        page.should <%= check_attr_to_have %>
      end
    end

    describe "Check ajax /<%= plural_table_name %>" do
      it "checks links on list page", :js => true do
        <%= singular_table_name %> = Factory(:<%= singular_table_name %>)
        visit <%= list_resources_path_test %>
        <%= "login_view_as(:user_manager)" if authentication? %>            #authentication
        page.find("div#list").should <%= check_attr_to_have %>
        click_link I18n.t(:show)
        page.find("div.ui-dialog").should <%= check_attr_to_have %>         #checks if dialog is appeared
        click_link "close"                                              #close dialog
        !page.find("div.ui-dialog").visible?                            #checks if dialog has been closed
        click_link I18n.t(:destroy)                                     #check ajax destroy
        page.driver.browser.switch_to.alert.accept                      #confirms destroy
        #save_and_open_page                                             #uncomment to debug
        page.find("div#list").should <%= check_attr_to_not_have %>          #checks if content has been removed
        !page.find("#tr#{<%= singular_table_name %>.id}").visible?         #checks if row has been hidden
      end
    end
  end
end
