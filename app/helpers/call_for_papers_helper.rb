module CallForPapersHelper
  require 'securerandom'

  def available_locales(conference)
    codes = conference.language_codes
    codes | Person.involved_in(conference).map { |p| p.languages.all }.flatten.map{|l| l.code.downcase }
  end

  def get_uuid
    SecureRandom.uuid
  end

end
