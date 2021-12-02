module PeopleHelper
  def person_languages
    if @conference
      priority_sort_languages(@person.translations.pluck(:locale) | @conference.language_codes)
    else
      priority_sort_languages(@person.translations.pluck(:locale))
    end
  end
end
