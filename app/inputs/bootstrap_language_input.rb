class BootstrapLanguageInput < FormtasticBootstrap::Inputs::SelectInput 
  
  def collection
    result = Array.new
    priority_languages = input_options.delete(:priority_languages) || nil
    if priority_languages
      result += LocalizedLanguageSelect::priority_languages_array(priority_languages)
      result << ["----------", ""]
    end
    result += LocalizedLanguageSelect::localized_languages_array(options)
  end

end
