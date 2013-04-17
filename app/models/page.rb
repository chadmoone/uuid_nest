class Page < ActiveRecord::Base
  include UUID
  belongs_to :book, primary_key: :uuid
end
