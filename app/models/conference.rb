class Conference < ActiveRecord::Base

  has_one :call_for_papers
  has_many :events
  has_many :rooms
  has_many :tracks
  has_many :languages, :as => :attachable

  accepts_nested_attributes_for :rooms, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :tracks, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :languages, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title, :acronym
  validates_uniqueness_of :acronym

  acts_as_audited

  def language_codes
    self.languages.map{|l| l.code.downcase}
  end

  def each_day(&block)
    day = self.first_day
    until (day > self.last_day)
      yield day
      day = day.since(1.days).to_date
    end
  end

  def to_s
    "Conference: #{self.title} (#{self.acronym})"
  end

end
