class Deck < ActiveRecord::Base
  include Tracer
  has_many :cards, autosave: true, primary_key: :uuid
  accepts_nested_attributes_for :cards, allow_destroy: true
end
