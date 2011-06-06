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

  def submission_data
    result = Hash.new
    events = self.events.order(:created_at)
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

  def language_breakdown
    result = Hash.new
    self.languages.each do |language|
      result[language.code] = self.events.where(:language => language.code).count
    end
    result["unknown"] = self.events.where(:language => "").count
    result
  end

  def language_codes
    self.languages.map{|l| l.code.downcase}
  end

  def days
    result = Array.new
    day = self.first_day
    until (day > self.last_day)
      result << day
      day = day.since(1.days).to_date
    end
    result
  end

  def each_day(&block)
    days.each(&block)
  end

  def to_s
    "Conference: #{self.title} (#{self.acronym})"
  end

end
