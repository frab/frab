class Event < ActiveRecord::Base
  include ActiveRecord::Transitions

  TYPES = [:lecture, :workshop, :podium, :lightning_talk, :meeting, :other]

  has_many :event_people
  has_many :event_feedbacks
  has_many :people, :through => :event_people
  has_many :links, :as => :linkable
  has_many :event_attachments
  has_many :event_ratings

  belongs_to :conference
  belongs_to :track
  belongs_to :room

  has_attached_file :logo, 
    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
    :default_url => "/images/event_:style.png"

  accepts_nested_attributes_for :event_people, :allow_destroy => true, :reject_if => Proc.new {|attr| attr[:person_id].blank?} 
  accepts_nested_attributes_for :links, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :event_attachments, :allow_destroy => true, :reject_if => :all_blank

  validates_attachment_content_type :logo, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :title, :time_slots

  acts_as_indexed :fields => [:title, :subtitle, :event_type, :abstract, :description]

  acts_as_audited 

  state_machine do
    state :new
    state :review
    state :withdrawn
    state :unconfirmed
    state :confirmed
    state :canceled
    state :rejected

    event :start_review do
      transitions :to => :review, :from => :new
    end
    event :withdraw do
      transitions :to => :withdrawn, :from => [:new, :review, :unconfirmed]
    end
    event :accept do
      transitions :to => :unconfirmed, :from => [:new, :review], :on_transition => :process_acceptance
    end
    event :confirm do
      transitions :to => :confirmed, :from => :unconfirmed
    end
    event :cancel do
      transitions :to => :canceled, :from => [:unconfirmed, :confirmed]
    end
    event :reject do
      transitions :to => :rejected, :from => [:new, :review], :on_transition => :process_rejection
    end
  end

  def self.ids_by_least_reviewed(conference, reviewer)
    already_reviewed = self.connection.select_rows("SELECT events.id FROM events JOIN event_ratings ON events.id = event_ratings.event_id WHERE events.conference_id = #{conference.id} AND event_ratings.person_id = #{reviewer.id}").flatten.map{|e| e.to_i}
    least_reviewed = self.connection.select_rows("SELECT events.id FROM events LEFT OUTER JOIN event_ratings ON events.id = event_ratings.event_id WHERE events.conference_id = #{conference.id} GROUP BY events.id ORDER BY COUNT(event_ratings.id) ASC, events.id ASC").flatten.map{|e| e.to_i}
    least_reviewed -= already_reviewed
    least_reviewed
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(self.current_state).include?(transition)
  end

  def average_feedback
    average(:event_feedbacks)
  end

  def recalculate_average_rating!
    self.update_attributes(:average_rating => average(:event_ratings))
  end

  def speakers
    self.event_people.where(:event_role => "speaker").all.map(&:person)
  end

  def to_s
    "Event: #{self.title}"
  end

  def process_acceptance(options)
    if options[:send_mail]
      self.event_people.where(:event_role => "speaker").each do |event_person|
        SelectionNotification.acceptance_notification(event_person).deliver
      end
    end
  end

  def process_rejection(options)
    if options[:send_mail]
      self.event_people.where(:event_role => "speaker").each do |event_person|
        SelectionNotification.rejection_notification(event_person).deliver
      end
    end
  end

  private

  def average(rating_type)
    result = 0
    rating_count = 0
    self.send(rating_type).each do |rating|
      if rating.rating
        result += rating.rating
        rating_count += 1
      end
    end
    if rating_count == 0
      return nil
    else
      return result.to_f / rating_count
    end
  end

end
