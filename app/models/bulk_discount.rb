class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant

  validates :percentage, presence: true, numericality: { only_integer: true }
  validates :threshold_quantity, presence: true, numericality: { only_integer: true }
end
