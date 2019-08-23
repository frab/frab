json.report do
  json.events @events do |event|
    json.extract! event, :id, :guid, :title
    json.extract! event, *@extra_fields
  end
  json.count @search_count
  json.report_type @report_type
end
