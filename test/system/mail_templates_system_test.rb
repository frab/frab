require 'application_system_test_case'

# Generated test cases
class MailTemplatesSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @orga = create(:conference_orga, conference: @conference)
  end

  test 'orga can view mail templates list' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/mail_templates"

    assert_content page, 'List of mail templates'
  end

  test 'orga can create new mail template' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/mail_templates"

    click_on 'Add mail template'

    fill_in 'Name', with: 'Welcome Email'
    fill_in 'Subject', with: 'Welcome to our conference'
    fill_in 'Content', with: 'Dear {public_name}, welcome to {conference}!'

    click_on 'Create Mail template'

    assert_content page, 'Mail template was successfully added'
    assert_content page, 'Welcome Email'
  end

  test 'orga can edit existing mail template' do
    mail_template = create(:mail_template,
      conference: @conference,
      name: 'Test Template',
      subject: 'Original Subject',
      content: 'Original content'
    )

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/mail_templates/#{mail_template.id}/edit"

    fill_in 'Subject', with: 'Updated Subject'
    click_on 'Update Mail template'

    assert_content page, 'Mail template was successfully updated'
    assert_content page, 'Updated Subject'
  end

  test 'orga can delete mail template' do
    mail_template = create(:mail_template,
      conference: @conference,
      name: 'Delete Me',
      subject: 'Test Subject',
      content: 'Test content'
    )

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/mail_templates"

    within('tr', text: 'Delete Me') do
      accept_confirm do
        find('.bi-trash').ancestor('form').find('button[type="submit"]').click
      end
    end

    assert_content page, 'Mail template was successfully destroyed'
    refute_content page, 'Delete Me'
  end

  test 'orga can send mail to speakers' do
    # Create an event with confirmed speakers to send mail to
    event = create(:event, conference: @conference, state: 'confirmed', public: true)
    speaker = create(:person)
    create(:event_person, event: event, person: speaker, event_role: 'speaker', role_state: 'confirmed')

    mail_template = create(:mail_template,
      conference: @conference,
      name: 'Speaker Notification',
      subject: 'Important Update',
      content: 'Hello {public_name}, this is an update for {conference}.'
    )

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/mail_templates/#{mail_template.id}"

    select 'All speakers involved in all confirmed events', from: 'send_filter'
    click_on 'Send'

    assert_content page, 'Mails delivered'
  end
end
