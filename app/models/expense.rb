class Expense < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference
end
