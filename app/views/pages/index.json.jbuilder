json.array!(@pages) do |page|
  json.extract! page, :uuid, :content, :book_id
  json.url page_url(page, format: :json)
end