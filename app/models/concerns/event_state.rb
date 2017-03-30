require 'active_support/concern'

module EventState
  extend ActiveSupport::Concern
  include ActiveRecord::Transitions

  included do
    state_machine do
      state :new
      state :review
      state :withdrawn
      state :canceled
      state :rejecting
      state :rejected
      state :accepting
      state :unconfirmed
      state :confirmed
      state :scheduled

      event :start_review do
        transitions to: :review, from: :new
      end
      event :withdraw do
        transitions to: :withdrawn, from: [:new, :review, :accepting, :unconfirmed]
      end
      event :accept do
        transitions to: :unconfirmed, from: [:new, :review], on_transition: :process_acceptance, :guard => lambda {|*args| !args[0].conference.bulk_notification_enabled }
        transitions to: :accepting, from: [:new, :review], on_transition: :process_acceptance, :guard => lambda {|*args| args[0].conference.bulk_notification_enabled }
      end
      event :notify do
        transitions to: :unconfirmed, from: :accepting, on_transition: :process_acceptance_notification, :guard => :notifiable
        transitions to: :rejected, from: :rejecting, on_transition: :process_rejection_notification, :guard => :notifiable
        transitions to: :scheduled, from: :confirmed, on_transition: :process_schedule_notification, :guard => :notifiable
      end
      event :confirm do
        transitions to: :confirmed, from: [:accepting, :unconfirmed]
      end
      event :cancel do
        transitions to: :canceled, from: [:accepting, :unconfirmed, :confirmed]
      end
      event :reject do
        transitions to: :rejected, from: [:new, :review], on_transition: :process_rejection, :guard => lambda {|*args| !args[0].conference.bulk_notification_enabled }
        transitions to: :rejecting, from: [:new, :review], on_transition: :process_rejection, :guard => lambda {|*args| args[0].conference.bulk_notification_enabled }
      end
    end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(self.current_state).include?(transition)
  end

  def notifiable
    return false unless conference.bulk_notification_enabled
    return false unless %w(accepting rejecting confirmed).include?(state)
    return false unless speakers.count.positive?
    return false unless speakers.all?(&:email)
    return false unless conference.ticket_type == 'integrated' or ticket.present?
    true
  end

  def process_acceptance(options)
    if options[:send_mail]
      self.event_people.presenter.each do |event_person|
        event_person.generate_token!
        SelectionNotification.make_notification(event_person, 'accept').deliver_now
      end
    end
    return unless options[:coordinator]
    return if self.event_people.find_by_person_id_and_event_role(options[:coordinator].id, 'coordinator')
    self.event_people.create(person: options[:coordinator], event_role: 'coordinator')
  end

  def process_rejection(options)
    if options[:send_mail]
      self.event_people.presenter.each do |event_person|
        SelectionNotification.make_notification(event_person, 'reject').deliver_now
      end
    end
    return unless options[:coordinator]
    return if self.event_people.find_by_person_id_and_event_role(options[:coordinator].id, 'coordinator')
    self.event_people.create(person: options[:coordinator], event_role: 'coordinator')
  end

  private

  def process_acceptance_notification
    process_bulk_notification 'accept'
  end

  def process_rejection_notification
    process_bulk_notification 'reject'
  end

  def process_schedule_notification
    process_bulk_notification 'schedule'
  end

  def process_bulk_notification(reason)
    self.event_people.presenter.each do |event_person|
      event_person.generate_token! if reason == 'accept'

      # XXX sending out bulk mails only works for rt and integrated
      if conference.ticket_type == 'rt'
        self.conference.ticket_server.add_correspondence(
          ticket.remote_ticket_id,
          event_person.substitute_notification_variables(reason, :subject),
          event_person.substitute_notification_variables(reason, :body),
          event_person.person.email
        )
      else
        SelectionNotification.make_notification(event_person, reason).deliver_now
      end
    end
  end
end
