module UUID extend ActiveSupport::Concern
  included do
    self.primary_key = "uuid"
    # validates :uuid, uniqueness: true
    before_create :build_uuid

    def build_uuid
      if new_record? && self.uuid.blank?
        self.uuid = UUIDTools::UUID.random_create.to_s
      end
    end
  end
end