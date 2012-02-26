require 'spec_helper'
<<<<<<< HEAD
<%- check_attr_to_have, check_attr_to_not_have = get_attr_to_match -%>
=======
<%-
items = []
attributes.each do |attribute|
  items << "        #{attribute_to_requests(attribute)}"
end
check_attr_to_have, check_attr_to_not_have = get_attr_to_match
-%>
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798

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
<<<<<<< HEAD
<%= fill_form_with_values.join(CRLF) %>
=======
<%= items.join(CRLF) %>
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798
        click_button "Create #{I18n.t('models.<%= singular_table_name %>')}"
        #save_and_open_page #uncomment to debug
        page.should have_content(I18n.t(:created, :model => I18n.t('models.<%= singular_table_name %>')))
        page.should <%= check_attr_to_have %>
      end
<<<<<<< HEAD

      it "copy one <%= singular_table_name %>" do
        <%= singular_table_name %> = Factory(:<%= singular_table_name %>)
        visit <%= list_resources_path_test %>
        <%= "login_view_as(:user_manager)" if authentication? -%>
        #save_and_open_page #uncomment to debug
        page.should <%= check_attr_to_have %>
        assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
        check("check#{<%= singular_table_name %>.id}")
        click_button I18n.t(:copy).upcase
        page.should have_content(I18n.t('attributes.<%= singular_table_name %>.op_copy'))
<%= fill_form_with_values("#{plural_table_name}_#_name").join(CRLF) %>
        click_button I18n.t(:submit)
        page.should have_content(I18n.t(:created, :model => I18n.t('models.<%= singular_table_name %>')))
      end

      it "copy several <%= plural_table_name %>" do
        <%- parents = []; str_parents_create = str_parents_where = "" -%>
        <%- base_parent_resources.each do |parent| -%>
        <%= parent %> = Factory(:<%= parent %>)
        <%- parents << ":#{parent}_id => #{parent}.id" -%>
        <%- end -%>
        <%- str_parents_create = ", #{parents.join(', ')}" if parents.any? -%>
        <%= plural_table_name %> = FactoryGirl.create_list(:<%= singular_table_name %>, 2<%= str_parents_create %>)
        visit <%= list_resources_path_test("#{plural_table_name}[0]") %>
        <%= "login_view_as(:user_manager)" if authentication? -%>
        #save_and_open_page #uncomment to debug
        <%= plural_table_name %>.each do |<%= singular_table_name %>|
          page.should <%= check_attr_to_have %>
          assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
          check "check#{<%= singular_table_name %>.id}"
        end
        click_button I18n.t(:copy).upcase
        page.should have_content(I18n.t('attributes.<%= singular_table_name %>.op_copy'))
        <%= plural_table_name %>.each do |<%= singular_table_name %>|
<%= fill_form_with_values("#{plural_table_name}_#_name").join(CRLF) %>
        end
        click_button I18n.t(:submit)
        page.should have_content(I18n.t(:created_multiple, :model => "#{<%= plural_table_name %>.size} #{I18n.t('models.<%= plural_table_name %>')}"))
      end

      it "edit one <%= singular_table_name %>" do
        <%= singular_table_name %> = Factory(:<%= singular_table_name %>)
        visit <%= list_resources_path_test %>
        <%= "login_view_as(:user_manager)" if authentication? -%>
        #save_and_open_page #uncomment to debug
        page.should <%= check_attr_to_have %>
        assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
        check("check#{<%= singular_table_name %>.id}")
        click_button I18n.t(:edit).upcase
        page.should have_content(I18n.t('attributes.<%= singular_table_name %>.op_edit_multiple'))
<%= fill_form_with_values("#{plural_table_name}_#_name").join(CRLF) %>
        click_button I18n.t(:submit)
        page.should have_content(I18n.t(:updated, :model => I18n.t('models.<%= singular_table_name %>')))
      end

      it "edit several <%= plural_table_name %>" do
        <%- parents = []; str_parents_create = str_parents_where = "" -%>
        <%- base_parent_resources.each do |parent| -%>
        <%= parent %> = Factory(:<%= parent %>)
        <%- parents << ":#{parent}_id => #{parent}.id" -%>
        <%- end -%>
        <%- str_parents_create = ", #{parents.join(', ')}" if parents.any? -%>
        <%= plural_table_name %> = FactoryGirl.create_list(:<%= singular_table_name %>, 2<%= str_parents_create %>)
        visit <%= list_resources_path_test("#{plural_table_name}[0]") %>
        <%= "login_view_as(:user_manager)" if authentication? -%>
        #save_and_open_page #uncomment to debug
        <%= plural_table_name %>.each do |<%= singular_table_name %>|
          page.should <%= check_attr_to_have %>
          assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
          check "check#{<%= singular_table_name %>.id}"
        end
        click_button I18n.t(:edit).upcase
        page.should have_content(I18n.t('attributes.<%= singular_table_name %>.op_edit_multiple'))
        <%= plural_table_name %>.each do |<%= singular_table_name %>|
  <%= fill_form_with_values("#{plural_table_name}_#_name").join(CRLF) %>
        end
        click_button I18n.t(:submit)
        page.should have_content(I18n.t(:updated_multiple, :model => "#{<%= plural_table_name %>.size} #{I18n.t('models.<%= plural_table_name %>')}"))
      end

      it "destroy one <%= singular_table_name %>" do
        <%= singular_table_name %> = Factory(:<%= singular_table_name %>)
        visit <%= list_resources_path_test %>
        <%= "login_view_as(:user_manager)" if authentication? -%>
        #save_and_open_page #uncomment to debug
        page.should <%= check_attr_to_have %>
        assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
        check("check#{<%= singular_table_name %>.id}")
        click_button I18n.t(:destroy).upcase
        page.should have_content(I18n.t(:deleted, :model => I18n.t('models.<%= singular_table_name %>')))
      end

      it "destroy several <%= plural_table_name %>" do
        <%- parents = []; str_parents_create = str_parents_where = "" -%>
        <%- base_parent_resources.each do |parent| -%>
        <%= parent %> = Factory(:<%= parent %>)
        <%- parents << ":#{parent}_id => #{parent}.id" -%>
        <%- end -%>
        <%- str_parents_create = ", #{parents.join(', ')}" if parents.any? -%>
        <%= plural_table_name %> = FactoryGirl.create_list(:<%= singular_table_name %>, 2<%= str_parents_create %>)
        visit <%= list_resources_path_test("#{plural_table_name}[0]") %>
        <%= "login_view_as(:user_manager)" if authentication? -%>
        #save_and_open_page #uncomment to debug
        <%= plural_table_name %>.each do |<%= singular_table_name %>|
          page.should <%= check_attr_to_have %>
          assert page.find("#tr#{<%= singular_table_name %>.id}").visible?
          check "check#{<%= singular_table_name %>.id}"
        end
        click_button I18n.t(:destroy).upcase
        page.should have_content(I18n.t(:deleted_multiple, :model => "#{<%= plural_table_name %>.size} #{I18n.t('models.<%= plural_table_name %>')}"))
      end
=======
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798
    end

    describe "Check ajax /<%= plural_table_name %>" do
      it "checks links on list page", :js => true do
        <%= singular_table_name %> = Factory(:<%= singular_table_name %>)
        visit <%= list_resources_path_test %>
        <%= "login_view_as(:user_manager)" if authentication? %>            #authentication
        page.find("div#list").should <%= check_attr_to_have %>
<<<<<<< HEAD
        click_link "#{<%= singular_table_name %>.id}"
=======
        click_link I18n.t(:show)
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798
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
