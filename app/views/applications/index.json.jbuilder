json.array!(@applications) do |application|
  json.extract! application, :id, :user_id, :name, :license_key
  json.url application_url(application, format: :json)
end
