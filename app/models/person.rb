class Person < ActiveRecord::Base
  GENDERS = %w(male female other)

  has_many :availabilities, dependent: :destroy
  has_many :event_people, dependent: :destroy
  has_many :event_ratings, dependent: :destroy
  has_many :events, -> { uniq }, through: :event_people
  has_many :im_accounts, dependent: :destroy
  has_many :languages, as: :attachable, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  has_many :phone_numbers, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :transport_needs, dependent: :destroy
  has_one :ticket, as: :object, dependent: :destroy

  accepts_nested_attributes_for :availabilities, reject_if: :all_blank
  accepts_nested_attributes_for :im_accounts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :languages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :phone_numbers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :ticket, reject_if: :all_blank, allow_destroy: true

  belongs_to :user, dependent: :destroy

  before_save :nilify_empty

  has_paper_trail

  has_attached_file :avatar,
    styles: { tiny: '16x16>', small: '32x32>', large: '128x128>' },
    default_url: 'person_:style.png'

  validates_attachment_content_type :avatar, content_type: [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :public_name, :email

  # validates_inclusion_of :gender, in: GENDERS, allow_nil: true

  scope :involved_in, ->(conference) {
    joins(events: :conference).where("conferences.id": conference.id).uniq
  }
  scope :speaking_at, ->(conference) {
    joins(events: :conference).where("conferences.id": conference.id).where("event_people.event_role": %w(speaker moderator)).where("events.state": %w(unconfirmed confirmed)).uniq
  }
  scope :publicly_speaking_at, ->(conference) {
    joins(events: :conference).where("conferences.id": conference.id).where("event_people.event_role": %w(speaker moderator)).where("events.public": true).where("events.state": %w(unconfirmed confirmed)).uniq
  }
  scope :confirmed, ->(conference) {
    joins(events: :conference).where("conferences.id": conference.id).where("events.state": 'confirmed')
  }

  def newer_than?(person)
    updated_at > person.updated_at
  end

  def full_name
    if first_name.blank? or last_name.blank?
      public_name
    else
      "#{first_name} #{last_name}"
    end
  end

  def full_name_annotated
    full_name + " (#{email}, \##{id})"
  end

  def user_email
    self.user.email if self.user.present?
  end

  def avatar_path(size = :large)
    self.avatar(size) if self.avatar.present?
  end

  def involved_in?(conference)
    found = Person.joins(events: :conference)
                  .where("conferences.id": conference.id)
                  .where(id: self.id)
                  .count
    found > 0
  end

  def active_in_any_conference?
    found = Conference.joins(events: [{ event_people: :person }])
                      .where(Event.arel_table[:state].in(%w(confirmed unconfirmed)))
                      .where(EventPerson.arel_table[:event_role].in(%w(speaker moderator)))
                      .where(Person.arel_table[:id].eq(self.id))
                      .count
    found > 0
  end

  def events_in(conference)
    self.events.where(conference_id: conference.id)
  end

  def events_as_presenter_in(conference)
    self.events.where("event_people.event_role": %w(speaker moderator), conference_id: conference.id)
  end

  def events_as_presenter_not_in(conference)
    self.events.where("event_people.event_role": %w(speaker moderator)).where('conference_id != ?', conference.id)
  end

  def public_and_accepted_events_as_speaker_in(conference)
    self.events.is_public.accepted.where("events.state": :confirmed, "event_people.event_role": %w(speaker moderator), conference_id: conference.id)
  end

  def role_state(conference)
    speaker_role_state(conference).map(&:role_state).uniq.join ', '
  end

  def set_role_state(conference, state)
    speaker_role_state(conference).each do |ep|
      ep.role_state = state
      ep.save!
    end
  end

  def availabilities_in(conference)
    availabilities = self.availabilities.where(conference_id: conference.id)
    availabilities.each { |a|
      a.start_date = a.start_date.in_time_zone
      a.end_date = a.end_date.in_time_zone
    }
    availabilities
  end

  def update_attributes_from_slider_form(params)
    # remove empty availabilities
    return unless params and params.key? 'availabilities_attributes'
    params['availabilities_attributes'].each { |_k, v|
      Availability.delete(v['id']) if v['start_date'].to_i == -1
    }
    params['availabilities_attributes'].select! { |_k, v| v['start_date'].to_i > 0 }
    # fix dates
    params['availabilities_attributes'].each { |_k, v|
      v['start_date'] = Time.zone.parse(v['start_date'])
      v['end_date'] = Time.zone.parse(v['end_date'])
    }
    self.update_attributes(params)
  end

  def average_feedback_as_speaker
    events = self.event_people.where(event_role: %w(speaker moderator)).map(&:event)
    feedback = 0.0
    count = 0
    events.each do |event|
      if current_feedback = event.average_feedback
        feedback += current_feedback * event.event_feedbacks_count
        count += event.event_feedbacks_count
      end
    end
    return nil if count == 0
    feedback / count
  end

  def locale_for_mailing(conference)
    own_locales = self.languages.all.map { |l| l.code.downcase.to_sym }
    conference_locales = conference.languages.all.map { |l| l.code.downcase.to_sym }
    return :en if own_locales.include? :en or own_locales.empty? or (own_locales & conference_locales).empty?
    (own_locales & conference_locales).first
  end

  def sum_of_expenses(conference, reimbursed)
    self.expenses.where(conference_id: conference.id, reimbursed: reimbursed).sum(:value)
  end

  def to_s
    "#{model_name.human}: #{self.full_name}"
  end

  def remote_ticket?
    ticket.present? and ticket.remote_ticket_id.present?
  end

  def merge_with(doppelgaenger, keep_last_updated = false)
    MergePersons.new(keep_last_updated).combine!(self, doppelgaenger)
  end

  private

  def speaker_role_state(conference)
    self.event_people.select { |ep| ep.event.conference == conference }.select { |ep| %w(speaker moderator).include? ep.event_role }
  end

  def nilify_empty
    self.gender = nil if self.gender and self.gender.empty?
  end
end
