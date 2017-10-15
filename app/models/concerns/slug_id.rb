module SlugId
  extend ActiveSupport::Concern

  included do
    include FriendlyId

    validates :slug, presence: true, uniqueness: true
    friendly_id :generate_slug, use: [:slugged, :finders], slug_column: :slug
  end

  def generate_slug
    canonical_type = self.class.table_name.singularize
    uuid = SecureRandom.urlsafe_base64(10)
    uuid.delete('-')
    "#{canonical_type}-#{uuid}"
  end
end
