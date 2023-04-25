require 'rails_helper'

RSpec.describe 'Merchant New Bulk Discounts', type: :feature do
  before(:each) do
    @merchant_1 = create(:merchant)
    @bulk_1 = create(:bulk_discount, percentage: 20, threshold_quantity: 10, merchant_id: @merchant_1.id)
  end

  describe 'Extension #3' do
    it 'prevents merchants from creating new discounts if they have discount(s) that would prevent the new one from being applied' do
      visit new_merchant_bulk_discount_path(@merchant_1)

      fill_in :bulk_discount_percentage, with: 15
      fill_in :bulk_discount_threshold_quantity, with: 15
      click_button("Add Discount")

      # expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
      expect(page).to have_content("Try again! You cannot create a discount that will not be applied.")
    end
  end
end
