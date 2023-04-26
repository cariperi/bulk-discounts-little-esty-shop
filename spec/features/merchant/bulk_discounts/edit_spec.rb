require 'rails_helper'

RSpec.describe 'Merchant Edit Bulk Discounts', type: :feature do
  before(:each) do
    @merchant_1 = create(:merchant)
    @bulk_1 = create(:bulk_discount, percentage: 20, threshold_quantity: 10, merchant_id: @merchant_1.id)
  end

  describe 'Extension #3' do
    it 'prevents merchants from editing a discount if they have discount(s) that would prevent the edited one from being applied' do
      visit edit_merchant_bulk_discount_path(@merchant_1, @bulk_1)

      fill_in :bulk_discount_percentage, with: 15
      fill_in :bulk_discount_threshold_quantity, with: 10
      click_button("Edit Discount")

      expect(page).to have_content("Try again! The attempted update would make this discount invalid.")

      visit edit_merchant_bulk_discount_path(@merchant_1, @bulk_1)

      fill_in :bulk_discount_percentage, with: 25
      fill_in :bulk_discount_threshold_quantity, with: 10
      click_button("Edit Discount")

      expect(page).to have_content("Discount successfully updated!")
    end
  end
end
