class Expense < ApplicationRecord
  belongs_to :person
  belongs_to :conference
  
  LARGEST_DECIMAL = 99999.9999
  validates_numericality_of :value, greater_than_or_equal_to: -LARGEST_DECIMAL, less_than_or_equal_to: LARGEST_DECIMAL
end
