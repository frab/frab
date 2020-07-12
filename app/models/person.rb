class Person < ApplicationRecord
  GENDERS = %w(male female other).freeze
  DEFAULT_AVATAR_SIZE = '32'.freeze

  has_many :availabilities, dependent: :destroy
  has_many :event_people, dependent: :destroy
  has_many :event_ratings, dependent: :destroy
  has_many :events, -> { distinct }, through: :event_people
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

  belongs_to :user, dependent: :destroy, optional: true

  before_save :nilify_empty

  has_paper_trail

  has_attached_file :avatar,
    styles: { tiny: '16x16>', small: '32x32>', large: '128x128>' },
    default_url: ':default_avatar_url',
    escape_url: false

  Paperclip.interpolates :default_avatar_url do |avatar, style|
    style = :small if style.blank? || style.eql?(:original)
    avatar.instance.default_avatar_url(style)
  end

  validates_attachment_content_type :avatar, content_type: [/jpg/, /jpeg/, /png/, /gif/]

  validates :public_name, :email, presence: true

  # validates_inclusion_of :gender, in: GENDERS, allow_nil: true

  scope :involved_in, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).distinct
  }
  scope :speaking_at, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).where('event_people.event_role': EventPerson::SPEAKERS).where('events.state': Event::ACCEPTED).distinct
  }
  scope :publicly_speaking_at, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).where('event_people.event_role': EventPerson::SPEAKERS).where('events.public': true).where('events.state': Event::ACCEPTED).distinct
  }
  scope :confirmed, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).where('events.state': %w(confirmed scheduled))
  }

  def self.fullname_options
    all.sort_by(&:full_name).map do |p|
      { id: p.id, text: p.full_name_annotated }
    end
  end

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
    user.email if user.present?
  end

  def avatar_path(size = :large)
    avatar(size) if avatar.present?
  end

  def involved_in?(conference)
    found = Person.joins(events: :conference)
      .where('conferences.id': conference.id)
      .where(id: id)
      .count
    found.positive?
  end

  def subscriber_of?(conferences)
    Person.joins(events: :conference)
      .where('conferences.id': conferences)
      .where('event_people.event_role': EventPerson::SUBSCRIBERS)
      .where(id: id)
      .any?
  end

  def active_in_any_conference?
    found = Conference.joins(events: [{ event_people: :person }])
      .where(Event.arel_table[:state].in(Event::ACCEPTED))
      .where(EventPerson.arel_table[:event_role].in(EventPerson::SUBSCRIBERS))
      .where(Person.arel_table[:id].eq(id))
      .count
    found.positive?
  end

  def events_in(conference)
    events.where(conference_id: conference.id)
  end

  def events_as_presenter_in(conference)
    events.where('event_people.event_role': EventPerson::SUBSCRIBERS, conference: conference)
  end

  def events_as_presenter_not_in(conference)
    events.where('event_people.event_role': EventPerson::SUBSCRIBERS).where.not(conference: conference)
  end

  def public_and_accepted_events_as_speaker_in(conference)
    events.is_public.accepted.where('events.state': %w(confirmed scheduled), 'event_people.event_role': EventPerson::SPEAKERS, conference_id: conference)
  end

  def role_state(conference)
    event_people.presenter_at(conference).map(&:role_state).compact.uniq.sort.join ', '
  end

  def set_role_state(conference, state)
    event_people.presenter_at(conference).each do |ep|
      ep.role_state = state
      ep.save!
    end
  end

  def update_from_omniauth(auth)
    unless ENV['OVERRIDE_PROFILE_PHOTO']
      return if avatar.present?
    end
    
    begin
      new_image_data = nil
      image_url = auth&.info&.image
      if image_url
        new_image_data = open(image_url).read
      else
        new_image_data = auth&.extra&.raw_info[:thumbnailphoto]&.first # Maybe Intel-specific
      end
      return unless new_image_data
      
      if avatar.exists?
        existing_avatar_data = Paperclip.io_adapters.for(avatar).read
        return if existing_avatar_data == new_image_data
      end
        
      update_attributes(avatar: StringIO.new(new_image_data),
                        avatar_file_name: auth.provider)
    rescue => e
      Rails.logger.error "Person::update_from_omniauth(provider=#{auth.provider}) exception during image import: #{e}; Ignored"
    end
  end

  def availabilities_in(conference)
    availabilities = self.availabilities.where(conference: conference)
    availabilities.each { |a|
      a.start_date = a.start_date.in_time_zone
      a.end_date = a.end_date.in_time_zone
    }
    availabilities
  end

  def create_availabilities_for(conference)
    Availability.build_for(conference).each do |a|
      a.person = self
      a.save
    end
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
    update_attributes(params)
  end

  def average_feedback_as_speaker
    events = event_people.where(event_role: EventPerson::SPEAKERS).map(&:event)
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
    own_locales = languages.all.map { |l| l.code.downcase.to_sym }
    conference_locales = conference.languages.all.map { |l| l.code.downcase.to_sym }
    return :en if own_locales.include? :en or own_locales.empty? or (own_locales & conference_locales).empty?
    (own_locales & conference_locales).first
  end

  def sum_of_expenses(conference, reimbursed)
    expenses.where(conference_id: conference.id, reimbursed: reimbursed).sum(:value)
  end

  def to_s
    "#{model_name.human}: #{full_name}"
  end

  def remote_ticket?
    ticket.present? and ticket.remote_ticket_id.present?
  end

  def merge_with(doppelgaenger, keep_last_updated = false)
    MergePersons.new(keep_last_updated).combine!(self, doppelgaenger)
  end

  def default_avatar_url(style = :small)
    return "person_#{style}.png" unless use_gravatar
    gravatar_url(gravatar_width(style))
  end

  private

  # size is of the format '32x32>' string
  def gravatar_width(style)
    avatar.styles[style][:geometry].split('x').first
  end

  def nilify_empty
    self.gender = nil if gender and gender.empty?
  end

  def gravatar_url(width = DEFAULT_AVATAR_SIZE)
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?size=#{width}&dd=mm"
  end
end
