class LanguageSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    @collection = []

    prepend_priority_languages(options.delete(:priority))
    @collection += LocalizedLanguageSelect::localized_languages_array(wrapper_options[:collection] || {})
    filter_collection(options[:only])

    super(wrapper_options)
  end

  private

  SEP = "----------"
  BLANK = ""

  def filter_collection(only)
    return unless only
    only += [SEP, BLANK]
    @collection.delete_if { |language, code| not code.in?(only) }
  end

  def prepend_priority_languages(priority_languages)
    return unless  priority_languages
    @collection += LocalizedLanguageSelect::priority_languages_array(priority_languages)
    @collection << [SEP, BLANK]
  end
end
