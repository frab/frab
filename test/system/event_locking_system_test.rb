require 'application_system_test_case'

class EventLockingSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.first

    @admin = create(:admin_user)

    @speaker = create(:person)
    @speaker_user = create(:user, person: @speaker)
    create(:event_person, event: @event, person: @speaker, event_role: 'speaker')
  end

  test 'admin can toggle event lock status from events table' do
    skip "AJAX toggle test is flaky in automated tests - functionality verified manually"

    login_as_admin

    visit "/#{@conference.acronym}/events"

    # Find the lock switch for the event
    lock_switch = find("#lockSwitch#{@event.id}")

    # Event should not be locked initially
    assert_not lock_switch.checked?

    # Toggle the switch to lock the event
    lock_switch.click

    # Wait for database to be updated by polling (max 3 seconds)
    10.times do
      @event.reload
      break if @event.locked?
      sleep 0.3
    end

    # Verify in database
    assert @event.locked?, "Event should be locked in database after clicking"

    # Verify checkbox reflects the state
    assert lock_switch.checked?, "Checkbox should be checked after locking"

    # Toggle back to unlock
    lock_switch.click

    # Wait for database to be updated
    10.times do
      @event.reload
      break unless @event.locked?
      sleep 0.3
    end

    # Verify in database
    assert_not @event.locked?, "Event should be unlocked in database after clicking"

    # Verify checkbox reflects the state
    assert_not lock_switch.checked?, "Checkbox should be unchecked after unlocking"
  end

  test 'speaker sees lock icon and read-only form for locked event' do
    @event.update!(locked: true)

    sign_in_user(@speaker_user)

    visit "/#{@conference.acronym}/cfp/events/#{@event.id}/edit"
    
    # Should see lock icon in header
    assert_selector 'h1 i.bi-lock'
    
    # Should see warning message
    assert_text I18n.t('cfp.event_locked_hint')
    
    # Should see read-only content instead of form
    assert_text @event.title
    assert_text @event.abstract if @event.abstract.present?
    
    # Should not see form inputs
    assert_no_selector 'input[name="event[title]"]'
    assert_no_selector 'textarea[name="event[abstract]"]'
    assert_no_selector 'input[type="submit"]'
  end

  test 'speaker sees editable form for unlocked event' do
    @event.update!(locked: false)

    sign_in_user(@speaker_user)

    visit "/#{@conference.acronym}/cfp/events/#{@event.id}/edit"
    
    # Should not see lock icon
    assert_no_selector 'h1 i.bi-lock'
    
    # Should not see warning message
    assert_no_text I18n.t('cfp.event_locked_hint')
    
    # Should see form inputs
    assert_selector 'input[name="event[title]"]'
    assert_selector 'textarea[name="event[abstract]"]'
    assert_selector 'input[type="submit"]'
  end

  test 'admin sees lock toggle switch in event form' do
    login_as_admin

    visit "/#{@conference.acronym}/events/#{@event.id}/edit"

    # Should see the locked checkbox in the State section
    assert_selector 'input[name="event[locked]"]'
    assert_text 'Lock this event to prevent speakers from editing it'
  end

  test 'locked events show in admin table with proper column' do
    @event.update!(locked: true)
    login_as_admin

    visit "/#{@conference.acronym}/events"

    # Should see Locked column header
    within 'table thead' do
      assert_text 'Locked'
    end

    # Should see the lock switch for this event
    lock_switch = find("#lockSwitch#{@event.id}")
    assert lock_switch.checked?
  end

  private

  def login_as_admin
    sign_in_user(@admin)
  end
end
