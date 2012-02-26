#Utility for general purpose
module Utility
  #Exports data from a collection using fastercsv gem
  def self.export(params={})
    require 'fastercsv'

    return "" unless params[:collection] && params[:collection].size>0
    collection = add_collection params[:collection]

    head = params[:head]
    head = collection.first.keys if !head && collection && collection.first
    head = [] unless head

    p18n = params[:i18n]
    p18n = "activerecord.attributes.#{params[:collection].first.class.to_s.downcase.to_sym}" if p18n == true #only if boolean and equal true
    p18n_generic = "activerecord.attributes.generic"

    str = FasterCSV.generate(:col_sep => params[:col_sep] || ";") do |csv|
      generic_fields = %w(id created_at updated_at)
      head.map!{|e| generic_fields.include?(e) ? I18n.t("#{p18n_generic}.#{e}") : I18n.t("#{p18n}.#{e}")} if p18n
      csv << head

      collection.each do |record|
        #each record is an hash
        csv << record.values.map do |v|
          case v.class.to_s
          when 'Time', 'Date'
            v.strftime "%d/%m/%Y"
          else
            v
          end
        end
      end
    end
    str
  end

  protected
  def self.add_collection in_collection
    return unless in_collection && in_collection.any?
    out_collection = []
    in_collection.each do |item|
       h = defined?(item.attributes) ? item.attributes : item
       out_collection << h
    end
    out_collection
  end
end
