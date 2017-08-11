json.data do
  json.array!(@database_calls) do |db_call|
    json.id db_call.id
    json.statement db_call.statement
    json.freq db_call.freq
    json.avg db_call.average
  end
end
