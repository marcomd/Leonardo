<% module_namespacing do -%>
class <%= leospaced? ? (base_namespaces << controller_class_name).join('/').camelize : controller_class_name %>Controller < ApplicationController
  helper_method :sort_column, :sort_direction
  <%= "before_filter :authenticate_user!#{CRLF}" if authentication? -%>
  <%= "load_and_authorize_resource#{CRLF}" if authorization? -%>
  <%#= "before_filter :load_parents#{CRLF}" if nested? -%>
before_filter :load_before

  def load_before
    @remote = <%= options.remote? %>
  <% base_parent_resources.each do |parent| -%>
  @<%= parent %> = <%= parent.classify %>.find params[:<%= parent %>_id]
  <% end -%>
end

  # GET <%= route_url %>
  # GET <%= route_url %>.json
  def index
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    conditions_fields = []
    conditions_values = []

    <%- base_parent_resources.each do |parent| -%>
      <%- if attributes.map(&:name).include? parent -%>
    conditions_fields << "#{<%= class_name %>.table_name}.<%= parent %>_id = ?"
    conditions_values << @<%= parent %>.id
      <%- end -%>
    <%- end -%>

    if params[:<%= singular_table_name %>]
      <%- attributes.each do |attribute| -%>
      <%- attr_name = case attribute.type
                 when :references, :belongs_to then "#{attribute.name}_id"
                 else attribute.name
              end -%>
      <%- conditions_operator_sign = case attribute.type
        when :string, :text then "LIKE"
        else "="
      end -%>
      <%- conditions_operator_value = case attribute.type
         when :string, :text then "%"
         else ""
      end -%>
      <% unless nested? && (attribute.type == :references || attribute.type == :belongs_to) -%>

      if params[:<%= singular_table_name %>][:<%= attr_name %>] && params[:<%= singular_table_name %>][:<%= attr_name %>].length>0
        conditions_fields << "#{<%= class_name %>.table_name}.<%= attr_name %> <%= conditions_operator_sign %> ?"
        conditions_values << "<%= conditions_operator_value %>#{params[:<%= singular_table_name %>][:<%= attr_name %>]}<%= conditions_operator_value %>"
        @<%= singular_table_name %>.<%= attr_name %> = params[:<%= singular_table_name %>][:<%= attr_name %>]
      end
      <%- end -%>
      <%- end -%>

    end

    conditions = [conditions_fields.join(' and ')] + conditions_values

    request.format = :csv if params[:commit] == 'Csv'
    
    @<%= plural_table_name %> = case request.format
    when 'text/html', 'text/javascript'
      <%= class_name %>.where(conditions).order("#{sort_column} #{sort_direction}")<%= ".page(params[:page])" if pagination? %>
    else
      <%= class_name %>.where(conditions)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render <%= key_value :json, "@#{plural_table_name}" %> }
      format.csv do
        send_data(Utility::export(:collection => @<%= plural_table_name %>,
                  #:column => [:column_name ],
                  :i18n => true
                  ),
          :type => 'text/csv; charset=utf-8; header=present',
          :filename => "#{CONFIG[:application][:name]}_#{t('models.<%= plural_table_name %>')}_#{Time.now.strftime("%Y%m%d")}.csv")
      end
      format.js
    end
  end

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.json
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      format.html # show.html.erb
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
      format.js
    end
  end

  # GET <%= route_url %>/new
  # GET <%= route_url %>/new.json
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    <%- if nested? -%>
    @<%= singular_table_name %>.<%= last_parent %>_id = @<%= last_parent %>.id
    <%- end -%>

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
    <%- if nested? -%>
    @<%= singular_table_name %>.<%= last_parent %>_id ||= @<%= last_parent %>.id
    <%- end -%>

    respond_to do |format|
      if @<%= orm_instance.save %>
        format.html { redirect_to <%= show_resource_path("@") %>, <%= key_value :notice, "I18n.t(:created, :model => I18n.t('models.#{singular_table_name}'))" %> }
        format.json { render <%= key_value :json, "@#{singular_table_name}" %>, <%= key_value :status, ':created' %>, <%= key_value :location, "@#{singular_table_name}" %> }
      else
        format.html { render <%= key_value :action, '"new"' %> }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
      end
    end
  end

  def create_multiple
    respond_to do |format|
      if <%= class_name %>.create(params[:<%= plural_table_name %>].values)
        num = params[:<%= plural_table_name %>].values.size
        format.html { redirect_to <%= list_resources_path %>, :notice => (num == 1 ? I18n.t(:created, :model => I18n.t('models.<%= singular_table_name %>')) : I18n.t(:created_multiple, :model => "#{num} #{I18n.t('models.<%= plural_table_name %>')}") ) }
      else
        format.html { render :action => "copy" }
      end
    end
  end

  # PUT <%= route_url %>/1
  # PUT <%= route_url %>/1.json
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        format.html { redirect_to <%= show_resource_path("@") %>, <%= key_value :notice, "I18n.t(:updated, :model => I18n.t('models.#{singular_table_name}'))" %> }
        format.json { head :ok }
      else
        format.html { render <%= key_value :action, '"edit"' %> }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
      end
    end
  end

  def update_multiple
    respond_to do |format|
      if <%= class_name %>.update(params[:<%= plural_table_name %>].keys, params[:<%= plural_table_name %>].values)
        num = params[:<%= plural_table_name %>].values.size
        format.html { redirect_to <%= list_resources_path %>, :notice => (num == 1 ? I18n.t(:updated, :model => I18n.t('models.<%= singular_table_name %>')) : I18n.t(:updated_multiple, :model => "#{num} #{I18n.t('models.<%= plural_table_name %>')}") ) }
      else
        format.html { render :action => "edit_multiple" }
      end
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.json
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>

    respond_to do |format|
      format.html { redirect_to <%= list_resources_path %> }
      format.json { head :ok }
      format.js
    end
  end

  def select
    if params[:ids]
      @<%= plural_table_name %> = <%= class_name %>.where("#{<%= class_name %>.table_name}.id" => params[:ids]).order("#{<%= class_name %>.table_name}.id")
      @operation = case params[:commit].downcase
        when I18n.t(:destroy).downcase then :destroy
        when I18n.t(:edit).downcase then :edit
        when I18n.t(:copy).downcase then :copy
        else :unknown_request
	    end
      @results = {}
      @<%= plural_table_name %>.each do |<%= singular_table_name %>|
        begin
          case @operation
          when :destroy
            <%= orm_instance.destroy %>
            @results[<%= singular_table_name %>.id] = [true, I18n.t(:deleted, :model => I18n.t('models.<%= singular_table_name %>'))]
          when :edit
            @results[<%= singular_table_name %>.id] = [true, ""]
          when :copy
            @results[<%= singular_table_name %>.id] = [true, ""]
          else
            raise I18n.t(@operation)
          end
        rescue
          @results[<%= singular_table_name %>.id] = [false, $!.message]
        end
      end

      respond_to do |format|
        format.js
        format.html do
          num_ok = num_ko = 0
          @results.each {|k, v| result, msg = v; result ? num_ok +=1 : num_ko +=1}
          case @operation
          when :destroy
            flash[:notice] = (num_ok == 1 ? I18n.t(:deleted, :model => I18n.t('models.<%= singular_table_name %>')) : I18n.t(:deleted_multiple, :model => "#{num_ok} #{I18n.t('models.<%= plural_table_name %>')}") ) if num_ok > 0
            flash[:error] = (num_ko == 1 ? I18n.t(:deleted_ko, :model => I18n.t('models.<%= singular_table_name %>')) : I18n.t(:deleted_multiple_ko, :model => "#{num_ko} #{I18n.t('models.<%= plural_table_name %>')}") ) if num_ko > 0
            redirect_to <%= list_resources_path %> and return
          when :edit
            render :edit_multiple and return
          when :copy
            render :copy and return
          else
            redirect_to root_path, :alert => I18n.t(:unknown_request) and return
          end
        end
      end
    else
      redirect_to <%= list_resources_path %>, :alert => I18n.t(:select_rows_from_list) and return
    end
  end

  private
    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end
    def sort_column
      <%= class_name %>.column_names.include?(params[:sort]) ? params[:sort] : "#{<%= class_name %>.table_name}.id"
    end
end
<% end -%>
