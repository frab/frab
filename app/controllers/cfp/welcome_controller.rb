class Cfp::WelcomeController < ApplicationController
  layout 'cfp'
  def show
    if current_user and session[:conference_acronym]
      flash.keep
      if redirect_submitter_to_edit?
        flash[:alert] = t('users_module.error_invalid_public_name')
        redirect_to edit_cfp_person_path(conference_acronym: session[:conference_acronym])
      else
        redirect_to cfp_person_path(conference_acronym: session[:conference_acronym]) if @conference.cfp_open?
      end
    end

    if @conference.call_for_participation.blank?
      render 'not_existing'
    elsif @conference.call_for_participation.in_the_future?
      render 'open_soon'
    end
  end
end
