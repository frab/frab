class StatisticsController < FrabApplicationController

  def events_by_state
    respond_to do |format|
      format.json { render :json => @conference.events_by_state.to_json }
    end
  end

  def language_breakdown
    result = @conference.language_breakdown(params[:accepted_only])

    respond_to do |format|
      format.json { render :json => result.to_json }
    end
  end

end
