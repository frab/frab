class ExpensesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :not_submitter!
  before_filter :find_person

  def new
    @expense = Expense.new
    flash[:alert] = "#{@person.full_name} does not currently have any expenses."
  end

  def edit
    @expense = @person.expenses.find(params[:id])
  end

  def index
    @expenses = @person.expenses.where(conference_id: @conference.id)
    @expenses_sum_reimbursed = @person.sum_of_expenses(@conference, true)
    @expenses_sum_non_reimbursed = @person.sum_of_expenses(@conference, false)
  end

  def update
    expense = @person.expenses.find(params[:id])
    expense.update_attributes(params[:expense])
    redirect_to(person_url(@person), notice: 'Expense was successfully updated.')
  end

  def create
    e = Expense.new(expenses_params)
    e.conference = @conference
    @person.expenses << e
    redirect_to(person_url(@person), notice: 'Expense was successfully added.')
  end

  def destroy
    @person.expenses.find(params[:id]).destroy
    redirect_to(person_url(@person), notice: 'Expense was successfully destroyed.')
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
    authorize! :administrate, @person
  end

  def expenses_params
    params.require(:expense).permit(:name, :reimbursed, :value)
  end
end
