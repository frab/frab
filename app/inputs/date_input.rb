class DateInput < FormtasticBootstrap::Inputs::StringInput

  def input_html_options 
    super.update(value: object.send(method).try(:to_s, :db))
  end

end
