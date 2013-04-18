class Page < ActiveRecord::Base
  include UUID
  include Tracer
  belongs_to :book, primary_key: :uuid
end
