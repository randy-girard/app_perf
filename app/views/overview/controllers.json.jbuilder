json.data do
  json.array!(@controllers) do |controller|
    json.controller controller.controller
    json.action controller.action
    json.freq controller.freq
    json.avg controller.average
  end
end
