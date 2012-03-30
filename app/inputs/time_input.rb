class TimeInput < FormtasticBootstrap::Inputs::StringInput

  def input_html_options 
    super.update(:value => object.send(method).try(:strftime, "%H:%M"))
  end

end
