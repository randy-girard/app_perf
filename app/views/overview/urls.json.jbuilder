json.data do
  json.array!(@urls) do |url|
    json.domain url.domain
    json.url url.url
    json.freq url.freq
    json.avg url.average
  end
end
