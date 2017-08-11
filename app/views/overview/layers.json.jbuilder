json.data do
  json.array!(@layers) do |layer|
    json.id layer.id
    json.name layer.name
    json.freq layer.freq
    json.avg layer.average
  end
end
