class Deck < ActiveRecord::Base
  has_many :cards, autosave: true
  accepts_nested_attributes_for :cards, allow_destroy: true
end

class Card < ActiveRecord::Base
  belongs_to :deck
end

class Book < ActiveRecord::Base
  include UUID
  has_many :pages, primary_key: :uuid, autosave: true
  accepts_nested_attributes_for :pages, allow_destroy: true
end

class Page < ActiveRecord::Base
  include UUID
  belongs_to :book, primary_key: :uuid
end

module UUID extend ActiveSupport::Concern
  included do
    self.primary_key = "uuid"
    validates :uuid, uniqueness: true
    before_create :build_uuid

    def build_uuid
      if new_record? && self.uuid.blank?
        self.uuid = UUIDTools::UUID.random_create.to_s
      end
    end
  end
end


def set_up
  r1 = Card.all.sample
  r2 = Card.find(23)
  r3 = Card.all.sample


  puts "\n\n---create deck:---"
  d = Deck.create(title: "My Deck")

  puts "\n\n---create book:---"
  b = Book.create(title: "My Book")

  puts "\n\n---create cards:---"
  c1 = Card.create({deck_id: d.id, content: "Lorem ipsum."})
  c2 = Card.create({deck_id: d.id, content: "Sit Dolor."})

  puts "\n\n---create pages:---"
  p1 = Page.create({book_id: b.id, content: "Lorem ipsum."})
  p2 = Page.create({book_id: b.id, content: "Sit Dolor."})

  puts "\n\n---update deck:---"
  begin
    d.update!({title: "New Deck", cards_attributes: [{uuid: c1.id, content: "Hello"}, {uuid: c2.id, content: "World!"}]})
  rescue Exception => e
    puts e.backtrace
  end
  
  puts "\n\n---update book:---"
  begin
    b.update!({title: "New Book", pages_attributes: [{uuid: p1.id, content: "Hello"}, {uuid: p2.id, content: "World!"}]})
  rescue Exception => e
    puts e.backtrace
  end

  puts "\n\n---refresh cards:---"
  c1.reload && c2.reload
  puts "c1(#{c1.valid?}): #{c1.content}"
  puts "c2(#{c2.valid?}): #{c2.content}"
  puts "---\n\n"

  puts "\n\n---refresh pages:---"
  p1.reload && p2.reload
  puts "p1(#{p1.valid?}): #{p1.content}"
  puts "p2(#{p2.valid?}): #{p2.content}"
  puts "---\n\n"


  puts "\n\n---delete card:---"
  begin
    d.update!({title: "Smaller Deck", cards_attributes: [{uuid: c1.id, _destroy: true}]})
  rescue Exception => e
    puts e.backtrace
  end
  
  puts "\n\n---delete page:---"
  begin
    b.update!({title: "Shorter Book", pages_attributes: [{uuid: p1.id, _destroy: true}]})
  rescue Exception => e
    puts e.backtrace
  end

  puts "\n\n---refresh deck:---"
  d.reload
  puts "d.cards(#{d.cards.count}): #{d.cards.inspect}"
  puts "---\n\n"

  puts "\n\n---refresh book:---"
  b.reload
  puts "b.pages(#{b.pages.count}): #{b.pages.inspect}"
  puts "---\n\n"

end

set_up

