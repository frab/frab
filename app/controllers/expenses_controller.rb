class ExpensesController < BaseConferenceController
  before_action :orga_only!
  before_action :find_person
  before_action :check_enabled

  def new
    @expense = Expense.new
    flash[:alert] = t('expenses_module.error_person_have_no_expense', {person: @person.full_name})
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
    expense.update_attributes(expenses_params)
    redirect_to(person_url(@person), notice: t('expenses_module.notice_expense_updated'))
  end

  def create
    e = Expense.new(expenses_params)
    e.conference = @conference
    @person.expenses << e
    redirect_to(person_url(@person), notice: t('expenses_module.notice_expense_created'))
  end

  def destroy
    @person.expenses.find(params[:id]).destroy
    redirect_to(person_url(@person), notice: t('expenses_module.notice_expense_destroyed'))
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
  end

  def check_enabled
    unless @conference.expenses_enabled?
      redirect_to(person_url(@person), notice: t('expenses_module.notice_expenses_disabled'))
    end
  end

  def expenses_params
    params.require(:expense).permit(:name, :reimbursed, :value)
  end
end
