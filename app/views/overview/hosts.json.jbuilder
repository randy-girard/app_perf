json.data do
  json.array!(@hosts) do |host|
    json.id host.id
    json.name host.name
    json.freq host.freq
    json.avg host.average
  end
end
