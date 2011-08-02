# Put here application's params

CONFIG = {
  :application => {
    :name => "<%= app_name %>",
    :version => "0.0.1",
    :started_at => "<%= Time.now.strftime('%d/%m/%Y') %>",
    :updated_at => "<%= Time.now.strftime('%d/%m/%Y') %>"
    },
  :default_style => "<%= style_name %>"
}