json.report do
  json.people @people do |person|
    json.extract! person, :id
    json.expenses person.expenses
  end
  json.total_sum @total_sum
  json.count @search_count
  json.report_type @report_type
end
