class Expense < ApplicationRecord
  belongs_to :person
  belongs_to :conference
end
