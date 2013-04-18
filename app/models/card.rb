class Card < ActiveRecord::Base
  include Tracer
  self.primary_key = :uuid
  belongs_to :deck
end
