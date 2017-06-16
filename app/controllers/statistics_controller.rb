class StatisticsController < BaseConferenceController
  before_action :crew_only!, except: %i[update_track update_event]

  def events_by_state
    case params[:type]
    when 'lectures'
      result = @conference.events_by_state_and_type(:lecture)
    when 'workshops'
      result = @conference.events_by_state_and_type(:workshop)
    when 'others'
      remaining = Event::TYPES - [:workshop, :lecture]
      result = @conference.events_by_state_and_type(remaining)
    else
      result = @conference.events_by_state
    end

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def language_breakdown
    result = @conference.language_breakdown(params[:accepted_only])

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def gender_breakdown
    result = @conference.gender_breakdown(params[:accepted_only])

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end
end
