class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  has_one :merchant, through: :item
  has_one :customer, through: :invoice
  has_many :transactions, -> { distinct }, through: :invoice

  validates :quantity, presence: true, numericality: true
  validates :unit_price, presence: true, numericality: true
  validates :status, presence: true

  enum status: ["Pending", "Packaged", "Shipped"]

  def get_discount_id
    result = InvoiceItem.where("invoice_items.id = ?", self.id)
                        .joins(item: :bulk_discounts)
                        .where('invoice_items.quantity >= bulk_discounts.threshold_quantity')
                        .order('bulk_discounts.percentage desc')
                        .select('invoice_items.*, bulk_discounts.*, bulk_discounts.id as bulk_discount_id')
                        .first

    result.nil? ? nil : result.bulk_discount_id
  end

  def discount_applied?
    get_discount_id.nil? == false
  end
end
