<<<<<<< HEAD
module Leonardo
  module Leosca

    protected
    def authorization?
      File.exists? "app/models/ability.rb"
    end
    def authentication?
      return true if File.exists? "app/models/user.rb"
      File.exists? "config/initializers/devise.rb"
    end
    def formtastic?
      return false unless options.formtastic?
      File.exists? "config/initializers/formtastic.rb"
    end
    def jquery_ui?
      File.exists? "vendor/assets/javascripts/jquery-ui"
    end
    def pagination?
      File.exists? "config/initializers/kaminari_config.rb"
    end
    def attribute_to_hash(attribute)
      name = case attribute.type
        when :references, :belongs_to then ":#{attribute.name}_id"
        else                               ":#{attribute.name}"
      end
      value = case attribute.type
        when :boolean                 then "true"
        when :integer                 then "#"
        when :float, :decimal         then "#.46"
        when :references, :belongs_to then "#"
        when :date                    then "#{Time.now.strftime("%Y-%m-%d 00:00:00.000")}".inspect
        when :datetime                then "#{Time.now.strftime("%Y-%m-%d %H:%M:%S.000")}".inspect
        when :time, :timestamp        then "#{Time.now.strftime("%H:%M:%S.000")}".inspect
        else                               "#{attribute.name.titleize}\#".inspect
      end
      " #{name} => #{value}"
    end
    def attribute_to_factories(attribute)
      spaces = 34
      space_association = " " * (spaces-11).abs
      space_sequence = " " * (spaces-attribute.name.size-11).abs
      space_other = " " * (spaces-attribute.name.size).abs
      name = case attribute.type
      when :references, :belongs_to   then "#{singular_table_name[0..0]}.association#{space_association}"
      when :boolean, :datetime, :time, :timestamp
                                      then "#{singular_table_name[0..0]}.#{attribute.name}#{space_other}"
      else                                 "#{singular_table_name[0..0]}.sequence(:#{attribute.name})#{space_sequence}"
      end
      value = case attribute.type
        when :boolean                 then "true"
        when :integer                 then "{|n| n }"
        when :float, :decimal         then "{|n| n }"
        when :references, :belongs_to then ":#{attribute.name}"
        when :date                    then "{|n| n.month.ago }"
        when :datetime                then "#{Time.now.strftime("%Y-%m-%d %H:%M:%S.000")}".inspect
        when :time, :timestamp        then "#{Time.now.strftime("%H:%M:%S.000")}".inspect
        else                               "{|n| \"#{attribute.name.titleize}\#{n}\" }"
      end
      "    #{name}#{value}"
    end
    def attribute_to_requests(attribute, object_id=nil)
      object_id ||= "#{singular_table_name}_#{attribute.name}"
      object_id = object_id.gsub('#', "\#{#{singular_table_name}.id}").gsub('name', attribute.name)
      case attribute.type
        when :boolean                 then "check \"#{object_id}\" if #{singular_table_name}.#{attribute.name}"
        when :references, :belongs_to then "select #{singular_table_name}.#{attribute.name}.name, :from => \"#{object_id}_id\""
        when :datetime, :time, :timestamp
                                      then ""
        when :date                    then "fill_in \"#{object_id}\", :with => #{singular_table_name}.#{attribute.name}.strftime('%d-%m-%Y')"
        else                               "fill_in \"#{object_id}\", :with => #{singular_table_name}.#{attribute.name}"
      end
    end
    def attribute_to_erb(attribute, object)
      case attribute.type
      when :boolean                   then "<%= #{object}.#{attribute.name} ? style_image_tag(\"ico_v.png\", :class => \"ico_true\") : style_image_tag(\"ico_x.png\", :class => \"ico_false\") %>"
      when :references, :belongs_to   then "<%= link_to(#{object}.#{attribute.name}.try(:name) || \"#\#{#{object}.#{attribute.name}.try(:id)}\", #{object}.#{attribute.name}, :remote => @remote) %>"
      when :integer                   then "<%= number_with_delimiter #{object}.#{attribute.name} %>"
      when :decimal                   then "<%= number_to_currency #{object}.#{attribute.name} %>"
      when :float                     then "<%= number_with_precision #{object}.#{attribute.name} %>"
      when :date                      then "<%= #{object}.#{attribute.name}.strftime('%d-%m-%Y') if #{object}.#{attribute.name} %>"
      when :datetime                  then "<%= #{object}.#{attribute.name}.strftime('%d-%m-%Y %H:%M:%S') if #{object}.#{attribute.name} %>"
      when :time, :timestamp          then "<%= #{object}.#{attribute.name}.strftime('%H:%M:%S') if #{object}.#{attribute.name} %>"
      else                                 "<%= #{object}.#{attribute.name} %>"
      end
    end
    def get_attr_to_match(view=:list)
      #attributes.each do |attribute|
      #  case attribute.type
      #  when :string, :text then
      #    return  "have_content(#{singular_table_name}.#{attribute.name})",
      #            "have_no_content(#{singular_table_name}.#{attribute.name})"
      #  end
      #end
      attr = get_attr_to_check(view)
      return  "have_content(#{singular_table_name}.#{attr})",
              "have_no_content(#{singular_table_name}.#{attr})" if attr

      #If there are not string or text attributes
      case view
      when :list
        return  "have_xpath('//table/tbody/tr')", "have_no_xpath('//table/tbody/tr')"
      when :show
        return  "have_xpath('//table/tbody/tr')", "have_no_xpath('//table/tbody/tr')"
      end
    end
    def get_attr_to_check(view=:list)
      case view
      when :something
      else
        attributes.each{|a| case a.type when :string, :text then return a.name end}
        attributes.each{|a| case a.type when :references, :belongs_to, :datetime then nil else return a.name end}
      end
    end
    def fill_form_with_values(object_id=nil)
      items = []
      attributes.each{|a|items << "        #{attribute_to_requests(a, object_id)}"}
      items
    end
  end

  module Nested
    protected

    #Add leonardo namespace to class_path
    #def class_path
    #  super + base_namespaces
    #end

    #product => products_path
    #product under category => category_products_path(@category)
    #product under brand/category => brand_category_products_path(@brand, @category)
    def list_resources_path
      "#{underscore_resource_path(:parent_singular_resource_plural)}_path(#{formatted_parent_resources("@")})"
    end

    #product under category => category_products_path(category)
    #product under brand/category => brand_category_products_path(@brand, category)
    #TODO: figure out how to build links for a particular resource in the path
    def list_resources_path_back
      return unless nested?
      "#{underscore_resource_path(:parent_singular_resource_plural)}_path(#{formatted_parent_resources("@").reverse.sub(/@/, "").reverse})"
    end

    #product => "product"
    #product under category => "[@category, product]"
    #product under brand/category => "[@brand, @category, product]"
    def destroy_resource_path(prefix_resource="")
      formatted_resource_path("@", prefix_resource, "[]")
    end

    #product => "product"
    #product under category => "[@category, product]"
    #product under brand/category => "[@brand, @category, product]"
    def show_resource_path(prefix_resource="")
      formatted_resource_path("@", prefix_resource, "[]")
    end

    #product => "@product"
    #product under category => "[@category, @product]"
    #product under brand/category => "[@brand, @category, @product]"
    def form_resource_path
      formatted_resource_path("@", "@", "[]")
    end

    #product => new_product_path
    #product under category => new_category_product_path(@category)
    #product under brand/category => new_brand_category_product_path(@brand, @category)
    def new_resource_path
      "new_#{underscore_resource_path}_path(#{formatted_parent_resources("@")})"
    end

    #product => edit_product_path(@product)
    #product under category => edit_category_product_path(@category, @product)
    #product under brand/category => edit_brand_category_product_path(@brand, @category, @product)
    def edit_resource_path(prefix_resource="")
      "edit_#{underscore_resource_path}_path(#{formatted_resource_path("@", prefix_resource)})"
    end

    #product under brand/category => "[brand, category, product]" or "[@brand, @category, @product]" or "@brand, @category, @product" or [product.brand, product.category, product]
    def formatted_resource_path(prefix_parent="", prefix_resource="", delimiter="", resource=nil)
      formatted_resource_base resource_path(prefix_parent, prefix_resource, resource), delimiter
    end

    #product under brand/category => "[brand, category]" or "[@brand, @category]" or "@brand, @category" or product.brand, product.category
    def formatted_parent_resources(prefix_parent="", delimiter="", resource=nil)
      prefix_parent = "#{resource}." if resource
      formatted_resource_base parent_resources(prefix_parent), delimiter
    end

    def formatted_resource_base(resources, delimiter="")
      str_resources = resources.join(', ')
      resources.size > 1 ? "#{delimiter[0..0]}#{str_resources}#{delimiter[1..1]}" : str_resources
    end

    #product under brand/category => "brand_category_product"
    def underscore_resource_path(names=:all_singular)
      case names
      when :all_singular
        resource_path.join('_')
      #when :all_plural
        #who needs?
      when :parent_singular_resource_plural
        resource_path.join('_').pluralize
      else
        "#{names.to_s}_not_supported"
      end
    end

    #product under brand/category => ["brand", "category", "product"] or ["@brand", "@category", "@product"]
    def resource_path(prefix_parent="", prefix_resource="", resource=nil, prefix_namespace="")
      if resource
        prefix_parent = "#{resource}."
      else
        resource = singular_table_name
      end

      prefix_namespace = ":" if prefix_namespace.empty? && prefix_parent.size>0

      if nested?
        (base_namespaces(prefix_namespace) + parent_resources(prefix_parent)) << "#{prefix_resource}#{resource}"
      else
        base_namespaces(prefix_namespace) << "#{prefix_resource}#{resource}"
      end
    end

    #product under brand/category => "categories"
    def plural_last_parent
      plural_parent_resources.last
    end

    #product under brand/category => ["brands", "categories"] or ["@brands", "@categories"]
    def plural_parent_resources(prefix_parent="")
      base_parent_resources.map{|m| "#{prefix_parent}#{m.pluralize}"}
    end

    #product under brand/category => ["brand", "category"] or ["@brand", "@category"]
    def parent_resources(prefix_parent="")
      base_parent_resources.map{|m| "#{prefix_parent}#{m}"}
    end

    #product under brand/category => "category"
    def last_parent
      base_parent_resources.last
    end

    #product under brand/category => ["brand", "category"]
    def base_parent_resources
      return [] unless options[:under].present?
      options[:under].split('/').map{|m| m.underscore}
    end

    def nested?
      options[:under].present?
    end

    ### NAMESPACE ###
    def leospaced?
      options[:leospace].present?
    end

    def base_namespaces(prefix="")
      return [] unless options[:leospace].present?
      options[:leospace].split('/').map{|m| "#{prefix}#{m.underscore}"}
    end

    def last_namespace(prefix="")
      base_namespaces(prefix).last
    end

    def formatted_namespace_path(separator='/')
      return "" unless leospaced?
      "#{base_namespaces.join(separator)}#{separator}"
    end

    module Test
      protected
      #Add parent(s) param(s) to request
      #get :index for a product under category => get :index, :category_id => product.category_id.to_s
      def nested_params_http_request(value=nil)
        return unless nested?
        ", " << base_parent_resources.map{|m| ":#{m}_id => #{value ? value.to_s.inspect : "#{file_name}.#{m}_id.to_s"}"}.join(', ')
      end

      #Create new parent(s) and add it to request
      #get :index for a product under category => get :index, :category_id => Factory(:category).id.to_s
      def nested_params_http_request_new_parent
        return unless nested?
        ", " << base_parent_resources.map{|m| ":#{m}_id => Factory(:#{m}).id.to_s"}.join(', ')
      end

      #product => products_path
      #product under category => category_products_path(product.category)
      #product under brand/category => brand_category_products_path(product.brand, product.category)
      def list_resources_path_test(resource=nil, prefix_parent=nil)
        unless prefix_parent
          resource ||= singular_table_name
          prefix_parent = "#{resource}."
        end
        "#{underscore_resource_path(:parent_singular_resource_plural)}_path(#{formatted_parent_resources(prefix_parent, "", resource)})"
      end

      #product => "product"
      #product under category => "[category, product]" or "[product.category, product]"
      #product under brand/category => "[brand, category, product]" or "[product.brand, product.category, product]"
      def show_resource_path_test(resource=nil, prefix_parent=nil, prefix_resource="")
        resource ||= singular_table_name
        prefix_parent = prefix_parent || "#{resource}."
        formatted_resource_path(prefix_parent, prefix_resource, "[]", resource)
      end

      #product => new_product_path
      #product under category => new_category_product_path(product.category)
      #product under brand/category => new_brand_category_product_path(product.brand, product.category)
      def new_resource_path_test(resource=nil, prefix_parent=nil)
        resource ||= singular_table_name
        prefix_parent = prefix_parent || "#{resource}."
        "new_#{underscore_resource_path}_path(#{formatted_parent_resources(prefix_parent, "",resource)})"
      end
    end
  end
=======
module Leonardo
  module Leosca

    protected
    def authorization?
      File.exists? "app/models/ability.rb"
    end
    def authentication?
      return true if File.exists? "app/models/user.rb"
      File.exists? "config/initializers/devise.rb"
    end
    def formtastic?
      return false unless options.formtastic?
      File.exists? "config/initializers/formtastic.rb"
    end
    def jquery_ui?
      File.exists? "vendor/assets/javascripts/jquery-ui"
    end
    def pagination?
      File.exists? "config/initializers/kaminari_config.rb"
    end
    def attribute_to_hash(attribute)
      name = case attribute.type
        when :references, :belongs_to then ":#{attribute.name}_id"
        else                               ":#{attribute.name}"
      end
      value = case attribute.type
        when :boolean                 then "true"
        when :integer                 then "#"
        when :float, :decimal         then "#.46"
        when :references, :belongs_to then "#"
        when :date                    then "#{Time.now.strftime("%Y-%m-%d 00:00:00.000")}".inspect
        when :datetime                then "#{Time.now.strftime("%Y-%m-%d %H:%M:%S.000")}".inspect
        when :time, :timestamp        then "#{Time.now.strftime("%H:%M:%S.000")}".inspect
        else                               "#{attribute.name.titleize}\#".inspect
      end
      " #{name} => #{value}"
    end
    def attribute_to_factories(attribute)
      str_space = " " * (20-attribute.name.size).abs
      name = case attribute.type
      when :references, :belongs_to   then "#{singular_table_name[0..0]}.association        #{str_space}"
      when :boolean, :datetime, :time, :timestamp
                                      then "#{singular_table_name[0..0]}.#{attribute.name}           #{str_space}"
      else                                 "#{singular_table_name[0..0]}.sequence(:#{attribute.name})#{str_space}"
      end
      value = case attribute.type
        when :boolean                 then "true"
        when :integer                 then "{|n| n }"
        when :float, :decimal         then "{|n| n }"
        when :references, :belongs_to then ":#{attribute.name}"
        when :date                    then "{|n| n.month.ago }"
        when :datetime                then "#{Time.now.strftime("%Y-%m-%d %H:%M:%S.000")}".inspect
        when :time, :timestamp        then "#{Time.now.strftime("%H:%M:%S.000")}".inspect
        else                               "{|n| \"#{attribute.name.titleize}\#{n}\" }"
      end
      "    #{name} #{value}"
    end
    def attribute_to_requests(attribute)
      case attribute.type
        when :boolean                 then "check '#{singular_table_name}_#{attribute.name}' if #{singular_table_name}.#{attribute.name}"
        when :references, :belongs_to then "select #{singular_table_name}.#{attribute.name}.name, :from => '#{singular_table_name}_#{attribute.name}_id'"
        when :datetime, :time, :timestamp
                                      then ""
        when :date                    then "fill_in '#{singular_table_name}_#{attribute.name}', :with => #{singular_table_name}.#{attribute.name}.strftime('%d-%m-%Y')"
        else                               "fill_in '#{singular_table_name}_#{attribute.name}', :with => #{singular_table_name}.#{attribute.name}"
      end
    end
    def attribute_to_erb(attribute, object)
      case attribute.type
      when :boolean                   then "<%= #{object}.#{attribute.name} ? style_image_tag(\"ico_v.png\", :class => \"ico_true\") : style_image_tag(\"ico_x.png\", :class => \"ico_false\") %>"
      when :references, :belongs_to   then "<%= link_to((#{object}.#{attribute.name}.try(:name) || \"\#{t('models.#{attribute.name}')} \#{#{object}.#{attribute.name}.try(:id)}\"), #{object}.#{attribute.name}, :remote => @remote) %>"
      when :integer                   then "<%= number_with_delimiter #{object}.#{attribute.name} %>"
      when :decimal                   then "<%= number_to_currency #{object}.#{attribute.name} %>"
      when :float                     then "<%= number_with_precision #{object}.#{attribute.name} %>"
      when :date                      then "<%= #{object}.#{attribute.name}.strftime('%d-%m-%Y') if #{object}.#{attribute.name} %>"
      when :datetime                  then "<%= #{object}.#{attribute.name}.strftime('%d-%m-%Y %H:%M:%S') if #{object}.#{attribute.name} %>"
      when :time, :timestamp          then "<%= #{object}.#{attribute.name}.strftime('%H:%M:%S') if #{object}.#{attribute.name} %>"
      else                                 "<%= #{object}.#{attribute.name} %>"
      end
    end
    def get_attr_to_match(view=:list)
      attributes.each do |attribute|
        return  "have_content(#{singular_table_name}.#{attribute.name})",
                "have_no_content(#{singular_table_name}.#{attribute.name})" if attribute.type==:string
      end
      #If there are not string attributes
      case view
      when :list
        return  "have_xpath('//table/tbody/tr')", "have_no_xpath('//table/tbody/tr')"
      when :show
        return  "have_xpath('//table/tbody/tr')", "have_no_xpath('//table/tbody/tr')"
      end
    end
  end

  module Nested
    protected

    #Add leonardo namespace to class_path
    #def class_path
    #  super + base_namespaces
    #end

    #product => products_path
    #product under category => category_products_path(@category)
    #product under brand/category => brand_category_products_path(@brand, @category)
    def list_resources_path
      "#{underscore_resource_path(:parent_singular_resource_plural)}_path(#{formatted_parent_resources("@")})"
    end

    #product under category => category_products_path(category)
    #product under brand/category => brand_category_products_path(@brand, category)
    #TODO: figure out how to build links for a particular resource in the path
    def list_resources_path_back
      return unless nested?
      "#{underscore_resource_path(:parent_singular_resource_plural)}_path(#{formatted_parent_resources("@").reverse.sub(/@/, "").reverse})"
    end

    #product => "product"
    #product under category => "[@category, product]"
    #product under brand/category => "[@brand, @category, product]"
    def destroy_resource_path(prefix_resource="")
      formatted_resource_path("@", prefix_resource, "[]")
    end

    #product => "product"
    #product under category => "[@category, product]"
    #product under brand/category => "[@brand, @category, product]"
    def show_resource_path(prefix_resource="")
      formatted_resource_path("@", prefix_resource, "[]")
    end

    #product => "@product"
    #product under category => "[@category, @product]"
    #product under brand/category => "[@brand, @category, @product]"
    def form_resource_path
      formatted_resource_path("@", "@", "[]")
    end

    #product => new_product_path
    #product under category => new_category_product_path(@category)
    #product under brand/category => new_brand_category_product_path(@brand, @category)
    def new_resource_path
      "new_#{underscore_resource_path}_path(#{formatted_parent_resources("@")})"
    end

    #product => edit_product_path(@product)
    #product under category => edit_category_product_path(@category, @product)
    #product under brand/category => edit_brand_category_product_path(@brand, @category, @product)
    def edit_resource_path(prefix_resource="")
      "edit_#{underscore_resource_path}_path(#{formatted_resource_path("@", prefix_resource)})"
    end

    #product under brand/category => "[brand, category, product]" or "[@brand, @category, @product]" or "@brand, @category, @product" or [product.brand, product.category, product]
    def formatted_resource_path(prefix_parent="", prefix_resource="", delimiter="", resource=nil)
      formatted_resource_base resource_path(prefix_parent, prefix_resource, resource), delimiter
    end

    #product under brand/category => "[brand, category]" or "[@brand, @category]" or "@brand, @category" or product.brand, product.category
    def formatted_parent_resources(prefix_parent="", delimiter="", resource=nil)
      prefix_parent = "#{resource}." if resource
      formatted_resource_base parent_resources(prefix_parent), delimiter
    end

    def formatted_resource_base(resources, delimiter="")
      str_resources = resources.join(', ')
      resources.size > 1 ? "#{delimiter[0..0]}#{str_resources}#{delimiter[1..1]}" : str_resources
    end

    #product under brand/category => "brand_category_product"
    def underscore_resource_path(names=:all_singular)
      case names
      when :all_singular
        resource_path.join('_')
      #when :all_plural
        #who needs?
      when :parent_singular_resource_plural
        resource_path.join('_').pluralize
      else
        "#{names.to_s}_not_supported"
      end
    end

    #product under brand/category => ["brand", "category", "product"] or ["@brand", "@category", "@product"]
    def resource_path(prefix_parent="", prefix_resource="", resource=nil, prefix_namespace="")
      if resource
        prefix_parent = "#{resource}."
      else
        resource = singular_table_name
      end

      prefix_namespace = ":" if prefix_namespace.empty? && prefix_parent.any?

      if nested?
        (base_namespaces(prefix_namespace) + parent_resources(prefix_parent)) << "#{prefix_resource}#{resource}"
      else
        base_namespaces(prefix_namespace) << "#{prefix_resource}#{resource}"
      end
    end

    #product under brand/category => "categories"
    def plural_last_parent
      plural_parent_resources.last
    end

    #product under brand/category => ["brands", "categories"] or ["@brands", "@categories"]
    def plural_parent_resources(prefix_parent="")
      base_parent_resources.map{|m| "#{prefix_parent}#{m.pluralize}"}
    end

    #product under brand/category => ["brand", "category"] or ["@brand", "@category"]
    def parent_resources(prefix_parent="")
      base_parent_resources.map{|m| "#{prefix_parent}#{m}"}
    end

    #product under brand/category => "category"
    def last_parent
      base_parent_resources.last
    end

    #product under brand/category => ["brand", "category"]
    def base_parent_resources
      return [] unless options[:under].present?
      options[:under].split('/').map{|m| m.underscore}
    end

    def nested?
      options[:under].present?
    end

    ### NAMESPACE ###
    def leospaced?
      options[:leospace].present?
    end

    def base_namespaces(prefix="")
      return [] unless options[:leospace].present?
      options[:leospace].split('/').map{|m| "#{prefix}#{m.underscore}"}
    end

    def last_namespace(prefix="")
      base_namespaces(prefix).last
    end

    def formatted_namespace_path(separator='/')
      return "" unless leospaced?
      "#{base_namespaces.join(separator)}#{separator}"
    end

    module Test
      protected
      #Add parent(s) param(s) to request
      #get :index for a product under category => get :index, :category_id => product.category_id.to_s
      def nested_params_http_request(value=nil)
        return unless nested?
        ", " << base_parent_resources.map{|m| ":#{m}_id => #{value ? value.to_s.inspect : "#{file_name}.#{m}_id.to_s"}"}.join(', ')
      end

      #Create new parent(s) and add it to request
      #get :index for a product under category => get :index, :category_id => Factory(:category).id.to_s
      def nested_params_http_request_new_parent
        return unless nested?
        ", " << base_parent_resources.map{|m| ":#{m}_id => Factory(:#{m}).id.to_s"}.join(', ')
      end

      #product => products_path
      #product under category => category_products_path(product.category)
      #product under brand/category => brand_category_products_path(product.brand, product.category)
      def list_resources_path_test(resource=nil, prefix_parent=nil)
        unless prefix_parent
          resource = resource || singular_table_name
          prefix_parent = "#{resource}."
        end
        "#{underscore_resource_path(:parent_singular_resource_plural)}_path(#{formatted_parent_resources(prefix_parent, "", resource)})"
      end

      #product => "product"
      #product under category => "[category, product]" or "[product.category, product]"
      #product under brand/category => "[brand, category, product]" or "[product.brand, product.category, product]"
      def show_resource_path_test(resource=nil, prefix_parent=nil, prefix_resource="")
        resource = resource || singular_table_name
        prefix_parent = prefix_parent || "#{resource}."
        formatted_resource_path(prefix_parent, prefix_resource, "[]", resource)
      end

      #product => new_product_path
      #product under category => new_category_product_path(product.category)
      #product under brand/category => new_brand_category_product_path(product.brand, product.category)
      def new_resource_path_test(resource=nil, prefix_parent=nil)
        resource = resource || singular_table_name
        prefix_parent = prefix_parent || "#{resource}."
        "new_#{underscore_resource_path}_path(#{formatted_parent_resources(prefix_parent, "",resource)})"
      end
    end
  end
>>>>>>> 730e2ecf07a73945550e3f0ea4a337ed132a4798
end