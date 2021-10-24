class Language < ApplicationRecord
  # These languages are supported by the UI via locales
  SUPPORTED = %w[en de es pt-BR fr zh ru it].freeze
  SUPPORTED_SYMS = %i[en de es pt-BR fr zh ru it].freeze

  # All languages, i.e. as they show up in the conferences language select
  # def self.possible
  #   I18n.translate(:languages).map { |k, _| k }
  # end

  def self.all_normalized
    I18n.translate(:languages).map { |k, _|
      Mobility.normalize_locale(k)
    }
  end

  belongs_to :attachable, polymorphic: true, optional: true
  validates :code, presence: true
end
