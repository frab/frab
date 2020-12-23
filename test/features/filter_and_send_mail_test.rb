require 'test_helper'

class FilterAndSendMailTest < FeatureTest
  BCC_ADDRESS = "jimmy@example.com"
  setup do
    ActionMailer::Base.deliveries = []
    @conference = create(:three_day_conference_with_events_and_speakers)
    @conference.update(bcc_address: BCC_ADDRESS)
    @event = @conference.events.last
    @admin = create(:admin_user)
  end

  it 'can create a template and use it for filter and send', js: true do
    sign_in_user(@admin)
    
    # Add mail template
    visit "/#{@conference.acronym}/mail_templates/new"
    fill_in 'Name', with: 'template1'
    fill_in 'Subject', with: 'mail regarding %{event}'
    fill_in 'Content', with: 'come to %{room} please. Event duration %{duration}'
    click_on 'Create Mail template'
    assert_content page, 'Mail template was successfully added'
    assert_content page, 'template1'

    # Filter
    visit "/#{@conference.acronym}/events"
    fill_in 'term', with: @event.title
    find("input#term").send_keys(:enter)

    @conference.events.each do |e|
      if e == @event
        assert_content page, e.title
      else
        refute_content page, e.title
      end
    end
    
    # and Send
    click_on 'Send mail to all these people'
    select 'template1', from: "template_name"
    find('input', id: 'bulk_email').trigger('click')
    
    assert_content page, 'Mails delivered'
    
    emails = ActionMailer::Base.deliveries                                      
    assert emails.count == 1 # without filtering, we would've seen 3            
    
    m = emails.first
    assert m.to == [ @event.event_people.where(event_role: :speaker).first.person.email ]
    assert m.subject == "mail regarding #{@event.title}"
    assert m.body.include? "come to #{@event.room.name} please"
    assert m.body.include? "duration 01:00"
    assert m.bcc.include? BCC_ADDRESS
  end
end

