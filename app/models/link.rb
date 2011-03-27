class Link < ActiveRecord::Base

  belongs_to :linkable, :polymorphic => true

  validates_presence_of :title, :url

  acts_as_audited :associated_with => :linkable

  def to_s
    "Link: #{self.title}"
  end

end
