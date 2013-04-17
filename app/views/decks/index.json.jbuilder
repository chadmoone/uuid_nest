json.array!(@decks) do |deck|
  json.extract! deck, :title
  json.url deck_url(deck, format: :json)
end