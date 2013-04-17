json.array!(@books) do |book|
  json.extract! book, :uuid, :title
  json.url book_url(book, format: :json)
end