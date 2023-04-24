class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, -> { distinct }, through: :invoice_items
  has_many :merchants, -> { distinct }, through: :items

  validates :status, presence: true

  enum status: ["In Progress", "Completed", "Cancelled"]

  def self.find_and_sort_incomplete_invoices
    joins(:invoice_items).where('invoice_items.status != ?', '2').group(:id).order(:created_at)
  end

  def self.find_with_successful_transactions
    joins(:transactions).where('transactions.result = true').distinct
  end

  def self.order_by_id
    order(:id)
  end

  def customer_name
    customer.first_name + " " + customer.last_name
  end

  def total_revenue
    invoice_items.sum('invoice_items.unit_price * quantity')
  end

  def total_revenue_for_merchant(merchant_id)
    invoice_items.select('invoice_items.*, items.merchant_id')
                 .joins(:item)
                 .where("items.merchant_id =  ?", merchant_id)
                 .sum('invoice_items.unit_price * quantity')
  end

  def discount_amount_for_merchant(merchant_id)
    InvoiceItem.select("unit_price, max_percent, quantity")
                 .from(invoice_items
                 .joins(item: :bulk_discounts)
                 .where("items.merchant_id = ?", merchant_id)
                 .where('quantity >= bulk_discounts.threshold_quantity')
                 .group('invoice_items.id')
                 .select("invoice_items.*, MAX(bulk_discounts.percentage) as max_percent"))
                 .sum("max_percent/100.0 * quantity * unit_price")
  end

  def total_discounted_revenue_for_merchant(merchant_id)
    total_revenue_for_merchant(merchant_id) - discount_amount_for_merchant(merchant_id)
  end
end
