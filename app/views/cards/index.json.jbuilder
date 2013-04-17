json.array!(@cards) do |card|
  json.extract! card, :content, :deck_id_id
  json.url card_url(card, format: :json)
end