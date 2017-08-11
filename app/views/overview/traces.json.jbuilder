json.data do
  json.array!(@traces) do |trace|
    json.id trace.id
    json.trace_key trace.trace_key
    json.url trace.arrange_spans.payload["url"]
    json.duration trace.duration
    json.timestamp trace.timestamp
  end
end
