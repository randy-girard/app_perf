json.data do
  json.array!(@percentiles) do |percentile|
    json.timestamp percentile.timestamp
    json.percentile_50 percentile.tile_50
    json.percentile_75 percentile.tile_75
    json.percentile_90 percentile.tile_90
    json.percentile_95 percentile.tile_95
    json.percentile_99 percentile.tile_99
  end
end
