require 'test_helper'

class MailTemplateTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
    @event = create(:event, state: 'confirmed')
    @mail_template = create(:mail_template, conference: @event.conference)

    @speaker = create(:person, include_in_mailings: true)
    @speaker.first_name = 'Frederick'
    @speaker.last_name = 'Besendorf'
    @speaker.save

    create(:event_person, event: @event, person: @speaker, event_role: 'speaker', role_state: 'confirmed')
  end

  test 'speaker gets email' do
    @mail_template.send_sync('all_speakers_in_confirmed_events')
    assert !ActionMailer::Base.deliveries.empty?
  end

  test 'person gets no email if not not matching filter' do
    @speaker.events = []
    @mail_template.send_sync('all_speakers_in_confirmed_events')
    assert ActionMailer::Base.deliveries.empty?
  end

  test 'mail content is personalized' do
    @mail_template.send_sync('all_speakers_in_confirmed_events')
    m = ActionMailer::Base.deliveries.first
    assert m.subject == "mail about #{@event.title}"
    assert m.body.include? "|first_name #{@speaker.first_name}|"
    assert m.body.include? "|last_name #{@speaker.last_name}|"
    assert m.body.include? "|public_name #{@speaker.public_name}|"
  end

  test 'ransack search by name returns matching templates' do
    results = MailTemplate.ransack(name_cont: @mail_template.name).result
    assert_includes results, @mail_template
  end

  test 'ransack search by name excludes non-matching templates' do
    other = create(:mail_template, conference: @event.conference, name: 'other_template')
    results = MailTemplate.ransack(name_cont: @mail_template.name).result
    assert_not_includes results, other
  end
end
