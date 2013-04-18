class Book < ActiveRecord::Base
  include UUID
  include Tracer

  has_many :pages, primary_key: :uuid, autosave: true
  accepts_nested_attributes_for :pages, allow_destroy: true
end
