class StatisticsController < ApplicationController

  def events_by_state
    respond_to do |format|
      format.json { render :json => @conference.events_by_state.to_json }
    end
  end

  def language_breakdown
    respond_to do |format|
      format.json { render :json => @conference.language_breakdown.to_json }
    end
  end

end
