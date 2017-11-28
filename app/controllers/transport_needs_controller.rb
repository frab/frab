class TransportNeedsController < BaseConferenceController
  before_action :find_person
  before_action :check_enabled
  before_action :orga_only!

  def new
    @transport_need = TransportNeed.new
    @transport_need.seats = 1
  end

  def edit
    @transport_need = @person.transport_needs.find(params[:id])
  end

  def index
    @transport_needs = @person.transport_needs.where(conference_id: @conference.id)
  end

  def update
    transport_need = @person.transport_needs.find(params[:id])
    transport_need.update_attributes(transport_needs_params)
    redirect_to(person_url(@person), notice: t('transport_needs_module.notice_need_updated'))
  end

  def create
    tn = TransportNeed.new(transport_needs_params)
    tn.conference = @conference
    @person.transport_needs << tn
    redirect_to(person_url(@person), notice: t('transport_needs_module.notice_need_created'))
  end

  def destroy
    @person.transport_needs.find(params[:id]).destroy
    redirect_to(person_url(@person), notice: t('transport_needs_module.notice_need_destroyed'))
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
  end

  def check_enabled
    unless @conference.transport_needs_enabled?
      redirect_to(person_url(@person), notice: t('transport_needs_module.notice_need_disabled'))
    end
  end

  def transport_needs_params
    params.require(:transport_need).permit(:at, :transport_type, :seats, :booked, :note)
  end
end
