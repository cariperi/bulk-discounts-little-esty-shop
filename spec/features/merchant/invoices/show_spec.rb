require 'rails_helper'

RSpec.describe 'Merchant Invoices Show Page', type: :feature do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @item_1 = create(:item, merchant_id: @merchant_1.id)
    @item_2 = create(:item, merchant_id: @merchant_1.id)
    @item_3 = create(:item, merchant_id: @merchant_1.id)
    @item_4 = create(:item, merchant_id: @merchant_1.id)
    @item_5 = create(:item, merchant_id: @merchant_1.id)
    @item_6 = create(:item, merchant_id: @merchant_2.id)
    @item_7 = create(:item, merchant_id: @merchant_2.id)
    @item_8 = create(:item, merchant_id: @merchant_1.id)

    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)
    @customer_4 = create(:customer)
    @customer_5 = create(:customer)
    @customer_6 = create(:customer)

    @invoice_1 = create(:invoice, customer_id: @customer_1.id, created_at: "2012-03-27 14:54:09 UTC")
    @invoice_2 = create(:invoice, customer_id: @customer_1.id)
    @invoice_3 = create(:invoice, customer_id: @customer_2.id)
    @invoice_4 = create(:invoice, customer_id: @customer_3.id)
    @invoice_5 = create(:invoice, customer_id: @customer_4.id)
    @invoice_6 = create(:invoice, customer_id: @customer_5.id)
    @invoice_7 = create(:invoice, customer_id: @customer_6.id)

    @transaction_1 = create(:transaction, invoice_id: @invoice_1.id, result: true) #customer_1
    @transaction_2 = create(:transaction, invoice_id: @invoice_1.id, result: true) #customer_1
    @transaction_3 = create(:transaction, invoice_id: @invoice_2.id, result: true) #customer_1
    @transaction_4 = create(:transaction, invoice_id: @invoice_2.id, result: true) #customer_1
    @transaction_5 = create(:transaction, invoice_id: @invoice_2.id, result: true) #customer_1
    @transaction_6 = create(:transaction, invoice_id: @invoice_2.id, result: true) #customer_1
    @transaction_7 = create(:transaction, invoice_id: @invoice_3.id, result: true) #customer_2
    @transaction_8 = create(:transaction, invoice_id: @invoice_3.id, result: true) #customer_2
    @transaction_9 = create(:transaction, invoice_id: @invoice_3.id, result: true) #customer_2
    @transaction_10 = create(:transaction, invoice_id: @invoice_3.id, result: true) #customer_2
    @transaction_11 = create(:transaction, invoice_id: @invoice_3.id, result: true) #customer_2
    @transaction_12 = create(:transaction, invoice_id: @invoice_4.id, result: true) #customer_3
    @transaction_13 = create(:transaction, invoice_id: @invoice_4.id, result: true) #customer_3
    @transaction_14 = create(:transaction, invoice_id: @invoice_4.id, result: true) #customer_3
    @transaction_15 = create(:transaction, invoice_id: @invoice_4.id, result: true) #customer_3
    @transaction_16 = create(:transaction, invoice_id: @invoice_5.id, result: true) #customer_4
    @transaction_17 = create(:transaction, invoice_id: @invoice_5.id, result: true) #customer_4
    @transaction_18 = create(:transaction, invoice_id: @invoice_5.id, result: true) #customer_4
    @transaction_19 = create(:transaction, invoice_id: @invoice_6.id, result: true) #customer_5
    @transaction_20 = create(:transaction, invoice_id: @invoice_6.id, result: true) #customer_5
    @transaction_21 = create(:transaction, invoice_id: @invoice_6.id, result: false) #customer_5
    @transaction_22 = create(:transaction, invoice_id: @invoice_7.id, result: true) #customer_6
    @transaction_23 = create(:transaction, invoice_id: @invoice_7.id, result: false) #customer_6

    @invoice_item_1 = create(:invoice_item, quantity: 100, unit_price: 15000, item_id: @item_1.id, invoice_id: @invoice_1.id, status: 0)
    @invoice_item_2 = create(:invoice_item, quantity: 1300, unit_price: 25000, item_id: @item_2.id, invoice_id: @invoice_1.id, status: 2)
    @invoice_item_3 = create(:invoice_item, item_id: @item_3.id, invoice_id: @invoice_3.id, status: 1)
    @invoice_item_4 = create(:invoice_item, item_id: @item_4.id, invoice_id: @invoice_4.id, status: 1)
    @invoice_item_5 = create(:invoice_item, item_id: @item_5.id, invoice_id: @invoice_5.id, status: 2)
    @invoice_item_6 = create(:invoice_item, item_id: @item_5.id, invoice_id: @invoice_6.id, status: 2)
    @invoice_item_7 = create(:invoice_item, item_id: @item_5.id, invoice_id: @invoice_7.id, status: 2)
    @invoice_item_8 = create(:invoice_item, item_id: @item_2.id, invoice_id: @invoice_5.id, status: 2)
    @invoice_item_9 = create(:invoice_item, item_id: @item_6.id, invoice_id: @invoice_7.id, status: 2)
    @invoice_item_10 = create(:invoice_item, item_id: @item_7.id, invoice_id: @invoice_1.id, status: 2) #check to see that total revenue only calculates for the specific merchant's items on an invoice
    @invoice_item_11 = create(:invoice_item, quantity: 5, unit_price: 30000, item_id: @item_8.id, invoice_id: @invoice_1.id, status: 2) #check to see that an item that does not match any discount threshold quantities is not included in discounts

    @bulk_1 = create(:bulk_discount, percentage: 10, threshold_quantity: 80, merchant_id: @merchant_1.id)
    @bulk_2 = create(:bulk_discount, percentage: 20, threshold_quantity: 500, merchant_id: @merchant_1.id)

    visit merchant_invoice_path(@merchant_1, @invoice_1)
  end

  it 'has a header' do
    expect(page).to have_content('Little Esty Shop')
  end

  it 'has the related invoice information, id, status, created at date in the format "Monday, July 18, 2019 (User Story 15)' do
    within '#invoice-info' do
      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_content(@invoice_1.status)
      expect(page).to have_content('Tuesday, March 27, 2012')
    end
  end

  it 'will display the customer first and last name (User Story 15)' do
    within '#customer-info' do
      expect(page).to have_content("Customer:")
      expect(page).to have_content(@customer_1.first_name)
      expect(page).to have_content(@customer_1.last_name)
    end
  end

  it 'will display the item names, quantity ordered, price sold for, and invoice item status (User Story 16)' do
    within "#item-info-#{@item_1.id}" do
      expect(page).to have_content("Item Name: #{@item_1.name}")
      expect(page).to have_content("Quantity: 100")
      expect(page).to have_content("Unit Price: $150")
      expect(page).to have_content("Status: Pending")
    end

    within "#item-info-#{@item_2.id}" do
      expect(page).to have_content("Item Name: #{@item_2.name}")
      expect(page).to have_content("Quantity: 1300")
      expect(page).to have_content("Unit Price: $250")
      expect(page).to have_content("Status: Shipped")
    end

    expect(page).to_not have_content(@item_7.name)
  end

  it 'will display the total revenue that will be generated from all of my items on the invoice (User Story 17)' do
    expect(page).to have_content("Total Revenue: $341,500.00")
  end

  it 'I will see the invoice item status for the item selected, when I click the select I can select a new status for the item with a button next to that says Update Item Status' do
    within "#item-info-#{@item_1.id}" do
      within "#selector" do
      expect(page).to have_button("Update Item Status")
      expect(page).to have_select("invoice_item_status", options: ['Pending', 'Packaged', 'Shipped'])
      expect(page).to have_content("Pending")
      end
    end

    within "#item-info-#{@item_2.id}" do
      within "#selector" do
        expect(page).to have_button("Update Item Status")
        expect(page).to have_select("invoice_item_status", options: ['Pending', 'Packaged', 'Shipped'])
        expect(page).to have_content("Shipped")
      end
    end
  end

  it 'when I select a new status and click the button I am taken back to the show page and see that the status is updated' do
    within "#item-info-#{@item_1.id}" do
      within "#selector" do
        select "Packaged", from: "invoice_item_status"
        click_button "Update Item Status"
      end

      expect(current_path).to eq(merchant_invoice_path(@merchant_1, @invoice_1))
      expect(page).to have_content("Packaged")
    end
  end

  it 'displays total revenue from all of the merchants items on this invoice' do
    item_revenue_1 = (@invoice_item_1.quantity * @invoice_item_1.unit_price)
    item_revenue_2 = (@invoice_item_2.quantity * @invoice_item_2.unit_price)
    item_revenue_3 = (@invoice_item_11.quantity * @invoice_item_11.unit_price)
    total_revenue = item_revenue_1 + item_revenue_2 + item_revenue_3

    expect(page).to have_content("Total Revenue: #{format_currency(total_revenue)}")
  end

  it 'displays total discounted revenue from all of the merchants items on this invoice' do
    item_revenue_1 = (@invoice_item_1.quantity * @invoice_item_1.unit_price) * ((100 - @bulk_1.percentage).fdiv(100))
    item_revenue_2 = (@invoice_item_2.quantity * @invoice_item_2.unit_price) * ((100 - @bulk_2.percentage).fdiv(100))
    item_revenue_3 = (@invoice_item_11.quantity * @invoice_item_11.unit_price)
    total_revenue = item_revenue_1 + item_revenue_2 + item_revenue_3

    expect(page).to have_content("Total Discounted Revenue: #{format_currency(total_revenue)}")
  end

  it 'includes a link to the show page for the bulk discount applied - if any - next to each invoice item' do
    within "#item-info-#{@item_1.id}" do
      expect(page).to have_link("Discount Applied")
      click_link "Discount Applied"
      expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @bulk_1))
    end

    visit merchant_invoice_path(@merchant_1, @invoice_1)

    within "#item-info-#{@item_2.id}" do
      expect(page).to have_link("Discount Applied")
      click_link "Discount Applied"
      expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @bulk_2))
    end

    visit merchant_invoice_path(@merchant_1, @invoice_1)

    within "#item-info-#{@item_8.id}" do
      expect(page).to_not have_link("Discount Applied")
      expect(page).to have_content("No discount applied.")
    end
  end
end
