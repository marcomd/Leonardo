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
end
