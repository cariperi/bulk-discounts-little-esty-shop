require 'rails_helper'

RSpec.describe 'Merchant Bulk Discounts Index Page', type: :feature do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @bulk_1 = create(:bulk_discount, percentage: 20, threshold_quantity: 10, merchant_id: @merchant_1.id)
    @bulk_2 = create(:bulk_discount, percentage: 30, threshold_quantity: 15, merchant_id: @merchant_1.id)
    @bulk_3 = create(:bulk_discount, percentage: 15, threshold_quantity: 5, merchant_id: @merchant_2.id)
  end

  it 'has a link to create a new discount that links to a form for to add a new bulk discount' do
    visit merchant_bulk_discounts_path(@merchant_1)

    expect(page).to have_link("Create a New Discount")
    click_link("Create a New Discount")

    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
    expect(page).to have_content("Enter details to create a new discount!")
    expect(page).to have_field(:percentage)
    expect(page).to have_field(:threshold_quantity)
    expect(page).to have_button("Add Discount")
  end

  it 'the form successfully creates a new bulk discount and redirects to the index when valid data is added' do
    visit new_merchant_bulk_discount_path(@merchant_1)
    expect(page).to_not have_content("Discount: 30%")
    expect(page).to_not have_content("Quantity Threshold: 20 items")

    fill_in :percentage with '30'
    fill_in :threshold_quantity with '20'
    click_button("Add Discount")

    expect(current_path).to eq(merchant_bulk_discounts_path(@merchant_1))
    expect(page).to have_content("Discount: 30%")
    expect(page).to have_content("Quantity Threshold: 20 items")
  end

  it 'the form displays an error and reloads the new discount page if invalid data is entered' do
    visit new_merchant_bulk_discount_path(@merchant_1)

    fill_in :percentage with '30'
    fill_in :threshold_quantity with 'X'
    click_button("Add Discount")

    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
    expect(page).to have_content("Invalid entry! Please try again.")
  end

  it 'the form displays an error and reloads the new discount page if no data is entered for a given field' do
    visit new_merchant_bulk_discount_path(@merchant_1)

    fill_in :percentage with '30'
    click_button("Add Discount")

    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
    expect(page).to have_content("Invalid entry! Please try again.")
  end
end
