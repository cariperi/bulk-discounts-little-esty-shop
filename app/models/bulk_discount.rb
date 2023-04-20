class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant

  validates :percentage, presence: true, numericality: true
  validates :threshold_quantity, presence: true, numericality: true
end
