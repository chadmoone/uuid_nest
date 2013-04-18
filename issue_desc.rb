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
  c1.reload
  c2.reload
  puts "\n\n---"
  puts "c1.valid? #{c1.valid?}"
  puts "c2.valid? #{c2.valid?}"
  puts c1.content
  puts c2.content
  puts "---\n\n"

  puts "\n\n---refresh pages:---"
  p1.reload
  p2.reload
  puts "\n\n---"
  puts "p1.valid? #{p1.valid?}"
  puts "p2.valid? #{p2.valid?}"
  puts p1.content
  puts p2.content

end

set_up

