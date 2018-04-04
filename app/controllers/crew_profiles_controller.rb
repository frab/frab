class CrewProfilesController < BaseCrewController
  def edit
    @person = current_user.person
  end

  def update
    @person = current_user.person

    respond_to do |format|
      if @person.update_attributes(person_params)
        format.html { redirect_to(edit_crew_profile_path, notice: t('users_module.notice_profile_updated')) }
      else
        flash_model_errors(@person)
        format.html { render action: 'edit' }
      end
    end
  end

  private

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, :note,
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy),
      ticket_attributes: %i(id remote_ticket_id)
    )
  end
end
