module CallForParticipationsHelper
  def available_locales(conference)
    codes = conference.language_codes
    codes | Person.involved_in(conference).map { |p| p.languages.all }.flatten.map { |l| l.code.downcase }
  end
  
  def encourage_register
    return false if @current_user&.persisted?
    Devise.mappings[:user].registerable?
  end
end
