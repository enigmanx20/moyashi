json.array!(@records) do |record|
  json.extract! record, :id
  json.url record_url(record, format: :json)
end
