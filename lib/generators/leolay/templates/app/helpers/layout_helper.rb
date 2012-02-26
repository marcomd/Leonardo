# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end

  def secondary_navigation(*items)
    outcome = '<ul>'
    items.compact.each do |h|
      outcome << "<li#{h[:active] ? " class='active'" : ""}>#{h[:value]}</li>"
    end
    outcome << '</ul>'
    outcome << '<div class="clear"></div>'
    content_for(:secondary_navigation) do
      outcome.html_safe
    end
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  #Search image from style path
  def style_image_tag(name,args={})
    image_tag("styles/#{CONFIG[:default_style]}/#{name}",args)
  end

  #Show search informations
  def page_entries_info(collection, singular_model_name, plural_model_name=nil)
    html = ""
    html << content_tag(:div, nil, :class => "separator")
    html << content_tag(:span, :class => "page_info") do
      if collection.any?
        t(:search_found, :found => pluralize(collection.total_count, singular_model_name, (plural_model_name || singular.pluralize)))
      else
        t(:search_not_found)
      end
    end
    html << content_tag(:div, nil, :class => "separator")
    html.html_safe
  end
end
