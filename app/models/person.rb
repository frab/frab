class Person < ActiveRecord::Base

  GENDERS = ["male", "female"]

  has_many :event_people
  has_many :phone_numbers
  has_many :im_accounts
  has_many :events, :through => :event_people
  has_many :links, :as => :linkable

  # ugly workaround. using formtastic and cocoon, _delete flag seems
  # to be inserted even for new records, so :reject_if => :all_blank
  # does not work. Need to investigate further.
  BLANK_OR_DELETE_PROC = Proc.new { |a| a.all?{|k,v| v.blank? || k == "_destroy"} }
  #accepts_nested_attributes_for :phone_numbers, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :phone_numbers, :reject_if => BLANK_OR_DELETE_PROC, :allow_destroy => true
  #accepts_nested_attributes_for :im_accounts, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :im_accounts, :reject_if => BLANK_OR_DELETE_PROC, :allow_destroy => true
  accepts_nested_attributes_for :links, :reject_if => BLANK_OR_DELETE_PROC, :allow_destroy => true

  belongs_to :user

  acts_as_indexed :fields => [:first_name, :last_name, :public_name, :email, :abstract, :description]
  
  has_attached_file :avatar, 
    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
    :default_url => "/images/person_:style.png"

  validates_attachment_content_type :avatar, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :first_name, :last_name, :email

  validates_inclusion_of :gender, :in => GENDERS, :allow_nil => true

  def full_name
    "#{first_name} #{last_name}"
  end
end
