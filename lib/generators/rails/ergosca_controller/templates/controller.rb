<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  # GET <%= route_url %>
  # GET <%= route_url %>.json
  def index
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    conditions = nil

    if params[:<%= singular_table_name %>]
      request.format = :csv if params[:commit] == 'Csv'
      conditions_fields = []
      conditions_values = []

      <%- attributes.each do |attribute| -%>
      if params[:<%= singular_table_name %>][:<%= attribute.name %>] && params[:<%= singular_table_name %>][:<%= attribute.name %>].length>0
        <%- conditions_operator_sign = case attribute.type
          when :string, :text then "LIKE"
          else "="
        end -%>
        <%- conditions_operator_value = case attribute.type
           when :string, :text then "%"
           else ""
        end -%>
        conditions_fields << "#{<%= class_name %>.table_name}.<%= attribute.name %> <%= conditions_operator_sign %> ?"
        conditions_values << "<%= conditions_operator_value %>#{params[:<%= singular_table_name %>][:<%= attribute.name %>]}<%= conditions_operator_value %>"
        @<%= singular_table_name %>.<%= attribute.name %> = params[:<%= singular_table_name %>][:<%= attribute.name %>]
      end
      <%- end -%>

      conditions = conditions_fields.join(' and ').to_a + conditions_values
    end

    request.format = :csv if params[:commit] == 'Csv'
    
    @<%= plural_table_name %> = case request.format
    when 'text/html'
      <%= class_name %>.where(conditions).order(:id).page(params[:page])
    else
      <%= class_name %>.where(conditions)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render <%= key_value :json, "@#{plural_table_name}" %> }
      format.csv {
        send_data(Utility::export(:collection => @<%= plural_table_name %>,
                  #:column => [:column_name ],
                  :i18n => true
                  ),
          :type => 'text/csv; charset=utf-8; header=present',
          :filename => "<%=CONFIG[:application][:name]%>_#{t('models.<%= plural_table_name %>')}_#{Time.now.strftime("%Y%m%d")}.csv")
      }
    end
  end

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.json
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      format.html # show.html.erb
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
    end
  end

  # GET <%= route_url %>/new
  # GET <%= route_url %>/new.json
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>

    respond_to do |format|
      format.html # new.html.erb
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
    end
  end

  # GET <%= route_url %>/1/edit
  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  # POST <%= route_url %>
  # POST <%= route_url %>.json
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        format.html { redirect_to @<%= singular_table_name %>, <%= key_value :notice, "I18n.t(:created, :model => I18n.t('models.#{singular_table_name}'))" %> }
        format.json { render <%= key_value :json, "@#{singular_table_name}" %>, <%= key_value :status, ':created' %>, <%= key_value :location, "@#{singular_table_name}" %> }
      else
        format.html { render <%= key_value :action, '"new"' %> }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
      end
    end
  end

  # PUT <%= route_url %>/1
  # PUT <%= route_url %>/1.json
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        format.html { redirect_to @<%= singular_table_name %>, <%= key_value :notice, "I18n.t(:updated, :model => I18n.t('models.#{singular_table_name}'))" %> }
        format.json { head :ok }
      else
        format.html { render <%= key_value :action, '"edit"' %> }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
      end
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.json
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>

    respond_to do |format|
      format.html { redirect_to <%= index_helper %>_url }
      format.json { head :ok }
    end
  end
end
<% end -%>
