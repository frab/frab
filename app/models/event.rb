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
      transitions :to => :unconfirmed, :from => [:new, :review]
    end
    event :confirm do
      transitions :to => :confirmed, :from => :unconfirmed
    end
    event :cancel do
      transitions :to => :canceled, :from => [:unconfirmed, :confirmed]
    end
    event :reject do
      transitions :to => :rejected, :from => [:new, :review]
    end
  end

  def self.submission_data(conference)
    result = Hash.new
    events = conference.events.order(:created_at)
    if events.size > 1
      date = events.first.created_at.to_date
      while date <= events.last.created_at.to_date
        result[date.to_time.to_i * 1000] = 0
        date = date.since(1.days).to_date
      end
    end
    events.each do |event|
      date = event.created_at.to_date.to_time.to_i * 1000
      result[date] = 0 unless result[date]
      result[date] += 1
    end
    result.to_a.sort
  end

  def next_by_least_reviews(reviewer)
    already_reviewed = self.class.connection.select_rows("SELECT events.id FROM events JOIN event_ratings ON events.id = event_ratings.event_id WHERE event_ratings.person_id = #{reviewer.id}").flatten.map{|e| e.to_i}
    already_reviewed.delete(self.id)
    least_reviewed = self.class.connection.select_rows("SELECT events.id FROM events LEFT OUTER JOIN event_ratings ON events.id = event_ratings.event_id WHERE events.conference_id = #{self.conference_id} GROUP BY events.id ORDER BY COUNT(event_ratings.id) DESC, events.id ASC").flatten.map{|e| e.to_i}
    least_reviewed -= already_reviewed
    return nil if least_reviewed.empty? or least_reviewed.last == self.id
    self.class.find(least_reviewed[least_reviewed.index(self.id)+1])
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

  def to_s
    "Event: #{self.title}"
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
