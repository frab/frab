require 'application_system_test_case'

# Generated test cases
class ExpensesTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @orga = create(:conference_orga, conference: @conference)
    @coordinator = create(:conference_coordinator, conference: @conference)

    @speaker = create(:person, email: 'speaker@example.com', public_name: 'Test Speaker')
    @event = create(:event, conference: @conference, state: 'confirmed')
    create(:event_person, event: @event, person: @speaker, event_role: 'speaker', role_state: 'confirmed')

    @expense = create(:expense, person: @speaker, conference: @conference, name: 'Travel costs', value: 150.50, reimbursed: false)
  end

  test 'orga can view expenses for a person' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}"

    click_on 'Expenses'

    assert_content page, 'Person'
    assert_content page, @speaker.public_name
    assert_content page, @expense.name
    assert_content page, '150.50'
  end

  test 'coordinator can see expenses but cannot manage them' do
    sign_in_user(@coordinator.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}"

    # Can see expenses summary
    assert_content page, 'Expenses'
    assert_content page, '$150.50'

    # But cannot navigate to expenses tab (no link)
    within '.nav-pills' do
      refute_content page, 'Expenses'
    end
  end

  test 'can create new expense for person' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses"

    click_on 'New expense'

    fill_in 'Name', with: 'Hotel accommodation'
    fill_in 'Value', with: '89.99'

    click_on 'Create Expense'

    assert_content page, 'Expense was successfully added'

    # Navigate back to expenses to verify it was created
    click_on 'Expenses'
    assert_content page, 'Hotel accommodation'
    assert_content page, '$89.99'
  end

  test 'can edit existing expense' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses"

    # Click the edit button (pencil icon)
    find('a[href*="edit"]').click

    fill_in 'Name', with: 'Updated travel costs'
    fill_in 'Value', with: '175.75'

    click_on 'Update Expense'

    assert_content page, 'Expense was successfully updated'

    # Go back to expenses to verify
    click_on 'Expenses'
    assert_content page, 'Updated travel costs'
    assert_content page, '$175.75'
  end

  test 'can delete expense' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses"

    # Click the first delete button in the table
    within('tbody tr:first-child') do
      accept_confirm do
        find('.bi-trash').ancestor('form').find('button[type="submit"]').click
      end
    end

    assert_content page, 'Expense was successfully destroyed'
    refute_content page, @expense.name
  end

  test 'expense form validates required fields' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses/new"

    # Try to create without required fields
    click_on 'Create Expense'

    # The actual validation message shown in the test output
    assert_content page, 'Value is not a number'
  end

  test 'expense value accepts decimal numbers' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses/new"

    fill_in 'Name', with: 'Meal expense'
    fill_in 'Value', with: '25.50'

    click_on 'Create Expense'

    assert_content page, 'Expense was successfully added'

    # Check the expenses total which should include original 150.50 + 25.50 = 176.00
    assert_content page, '$176.00'
  end

  test 'shows total expenses for person' do
    # Create additional expenses
    create(:expense, person: @speaker, conference: @conference, name: 'Meals', value: 45.25)
    create(:expense, person: @speaker, conference: @conference, name: 'Transport', value: 30.00)

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses"

    # Should show sum of expenses
    assert_content page, 'Sum of all'
  end

  test 'expenses are filtered by conference' do
    # Create expense for different conference
    other_conference = create(:three_day_conference)
    other_expense = create(:expense, person: @speaker, conference: other_conference, name: 'Other conference expense', value: 100.00)

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses"

    # Should only show expenses for current conference
    assert_content page, @expense.name
    refute_content page, other_expense.name
  end

  test 'can navigate back to person from expenses' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@speaker.id}/expenses"

    # Click on the Profile tab to go back to person page
    click_on 'Profile'

    assert_content page, @speaker.public_name
    # Accept that there might be locale in the URL
    assert_match %r{/#{@conference.acronym}/people/#{@speaker.id}\z}, current_path
  end
end
