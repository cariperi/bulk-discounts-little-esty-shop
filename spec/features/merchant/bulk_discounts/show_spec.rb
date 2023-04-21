require 'rails_helper'

RSpec.describe 'Bulk Discount Show Page', type: :feature do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @bulk_1 = create(:bulk_discount, percentage: 20, threshold_quantity: 10, merchant_id: @merchant_1.id)
    @bulk_2 = create(:bulk_discount, percentage: 30, threshold_quantity: 15, merchant_id: @merchant_1.id)
    @bulk_3 = create(:bulk_discount, percentage: 15, threshold_quantity: 5, merchant_id: @merchant_2.id)
  end

  it 'displays the specific bulk discounts percentage and quantity threshold' do
    visit merchant_bulk_discount_path(@merchant_1, @bulk_1)

    expect(page).to have_content("Bulk Discount ID: #{@bulk_1.id}")
    expect(page).to have_content("Discount: #{@bulk_1.percentage}%")
    expect(page).to have_content("Quantity Threshold: #{@bulk_1.threshold_quantity} items")
    expect(page).to_not have_content("Bulk Discount ID: #{@bulk_2.id}")

    visit merchant_bulk_discount_path(@merchant_2, @bulk_3)

    expect(page).to have_content("Bulk Discount ID: #{@bulk_3.id}")
    expect(page).to have_content("Discount: #{@bulk_3.percentage}%")
    expect(page).to have_content("Quantity Threshold: #{@bulk_3.threshold_quantity} items")
    expect(page).to_not have_content("Bulk Discount ID: #{@bulk_2.id}")
  end
end
