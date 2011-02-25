class Event < ActiveRecord::Base

  has_many :event_attachments
  has_many :event_people
  has_many :people, :through => :event_people
  has_many :links, :as => :linkable

  belongs_to :conference

  has_attached_file :logo, 
    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
    :default_url => "/images/event_:style.png"

  accepts_nested_attributes_for :event_attachments
  accepts_nested_attributes_for :event_people
  accepts_nested_attributes_for :links

  validates_attachment_content_type :logo, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  acts_as_indexed :fields => [:title, :subtitle, :event_type, :abstract, :description]

end
