class TransportNeedsController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  before_action :find_person
  before_action :check_enabled

  def new
    @transport_need = TransportNeed.new
    @transport_need.seats = 1
  end

  def edit
    @transport_need = @person.transport_needs.find(params[:id])
  end

  def index
    @transport_needs = @person.transport_needs.where(:conference_id => @conference.id)
  end

  def update
    transport_need = @person.transport_needs.find(params[:id])
    transport_need.update_attributes(transport_needs_params)
    redirect_to(person_url(@person), notice: 'Transport need was successfully updated.')
  end

  def create
    tn = TransportNeed.new(transport_needs_params)
    tn.conference = @conference
    @person.transport_needs << tn
    redirect_to(person_url(@person), notice: 'Transport need was successfully added.')
  end

  def destroy
    @person.transport_needs.find(params[:id]).destroy
    redirect_to(person_url(@person), notice: 'Transport need was successfully destroyed.')
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
    authorize! :administrate, @person
  end

  def check_enabled
    unless @conference.transport_needs_enabled?
      redirect_to(person_url(@person), notice: 'Transport needs are not enabled for this conference')
    end
  end

  def transport_needs_params
    params.require(:transport_need).permit(:at, :transport_type, :seats, :booked, :note)
  end

end
