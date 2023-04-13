class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items

  validates :status, presence: true
 
  enum status: ["In Progress", "Completed", "Cancelled"]

  def customer_name
    customer.first_name + " " + customer.last_name
  end
end