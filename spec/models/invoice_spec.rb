require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "relationships" do
    it { should belong_to(:customer) }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should define_enum_for(:status) }
  end

  describe 'class methods' do
    describe '.find_and_sort_incomplete_invoices' do
      it 'returns all invoices that have items that have not yet shipped, sorted by creation date (oldest to newest)' do
        merchant = create(:merchant)
        customer = create(:customer)

        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant)
        item_4 = create(:item, merchant: merchant)
        item_5 = create(:item, merchant: merchant)
        item_6 = create(:item, merchant: merchant)
        item_7 = create(:item, merchant: merchant)
        item_8 = create(:item, merchant: merchant)

        @invoice_1 = create(:invoice, created_at: '2023-03-26 09:54:09 UTC', customer: customer) # newest creation date
        @invoice_2 = create(:invoice, created_at: '2023-03-24 09:54:09 UTC', customer: customer) # oldest creation date
        @invoice_3 = create(:invoice, created_at: '2023-03-25 09:54:09 UTC', customer: customer) # middle creation date
        @invoice_4 = create(:invoice, created_at: '2023-03-26 09:54:09 UTC', customer: customer) # 2 shipped items - expect to be excluded


        @invoice_item_1 = create(:invoice_item, status: "Pending", item: item_1, invoice: @invoice_1)
        @invoice_item_2 = create(:invoice_item, status: "Packaged", item: item_2, invoice: @invoice_1)
        @invoice_item_3 = create(:invoice_item, status: "Pending", item: item_3, invoice: @invoice_2)
        @invoice_item_4 = create(:invoice_item, status: "Shipped", item: item_4, invoice: @invoice_2)
        @invoice_item_5 = create(:invoice_item, status: "Packaged", item: item_5, invoice: @invoice_3)
        @invoice_item_6 = create(:invoice_item, status: "Shipped", item: item_6, invoice: @invoice_3)
        @invoice_item_7 = create(:invoice_item, status: "Shipped", item: item_7, invoice: @invoice_4)
        @invoice_item_8 = create(:invoice_item, status: "Shipped", item: item_8, invoice: @invoice_4)

        expect(Invoice.find_and_sort_incomplete_invoices).to eq([@invoice_2, @invoice_3, @invoice_1])
      end
    end

    describe '.find_with_successful_transactions' do
      it 'returns all invoices with at least one successful transaction' do
        customer = create(:customer)

        invoice_1 = create(:invoice, created_at: '2023-01-01 20:54:10 UTC', customer: customer) # has only successful transactions
        invoice_2 = create(:invoice, created_at: '2023-01-02 20:54:10 UTC', customer: customer) # has 2 successful transactions and 1 un-successful transaction
        invoice_3 = create(:invoice, created_at: '2023-01-03 20:54:10 UTC', customer: customer) # has 1 successful transactions and 2 un-successful transactions
        invoice_4 = create(:invoice, created_at: '2023-01-04 20:54:10 UTC', customer: customer) # has no successful transactions

        transaction_1 = create(:transaction, result: true, invoice: invoice_1)
        transaction_2 = create(:transaction, result: true, invoice: invoice_1)
        transaction_3 = create(:transaction, result: true, invoice: invoice_1)
        transaction_4 = create(:transaction, result: true, invoice: invoice_2)
        transaction_5 = create(:transaction, result: true, invoice: invoice_2)
        transaction_6 = create(:transaction, result: false, invoice: invoice_2)
        transaction_7 = create(:transaction, result: true, invoice: invoice_3)
        transaction_8 = create(:transaction, result: false, invoice: invoice_3)
        transaction_9 = create(:transaction, result: false, invoice: invoice_3)
        transaction_10 = create(:transaction, result: false, invoice: invoice_4)
        transaction_11 = create(:transaction, result: false, invoice: invoice_4)
        transaction_12 = create(:transaction, result: false, invoice: invoice_4)

        expect(Invoice.find_with_successful_transactions).to include(invoice_1, invoice_2, invoice_3)
      end
    end

    describe ":order_by_id" do
      it "orders all invoices by id" do

        customer_1 = create(:customer)
        invoice_3 = create(:invoice, id: 1, customer_id: customer_1.id)
        invoice_2 = create(:invoice, id: 2 ,customer_id: customer_1.id)
        invoice_1 = create(:invoice, id: 3 ,customer_id: customer_1.id)

        expect(Invoice.order_by_id.first).to eq(invoice_3)
        expect(Invoice.order_by_id.second).to eq(invoice_2)
        expect(Invoice.order_by_id.third).to eq(invoice_1)
      end
    end
  end

  describe "instance methods" do
    describe 'customer_name' do
      it 'returns the name of the customer' do
        @customer = create(:customer, first_name: "Bob", last_name: "Smith")
        @invoice = create(:invoice, customer_id: @customer.id)

        expect(@invoice.customer_name).to eq("Bob Smith")
      end
    end

    describe 'merchant_items(merchant_id)' do
      it 'returns the invoice items that belong to a specific merchant' do
        merchant_1 = create(:merchant)
        merchant_2 = create(:merchant)
        customer_1 = create(:customer)
        invoice_1 = create(:invoice, customer_id: customer_1.id)
        invoice_2 = create(:invoice, customer_id: customer_1.id)
        item_1 = create(:item, merchant_id: merchant_1.id)
        item_2 = create(:item, merchant_id: merchant_1.id)
        item_3 = create(:item, merchant_id: merchant_2.id)
        invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, quantity: 10, unit_price: 1000)
        invoice_item_2 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 1000, unit_price: 100)
        invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_3.id, quantity: 50, unit_price: 500)

        expect(invoice_1.merchant_items(merchant_1.id)).to eq([invoice_item_1, invoice_item_2])
      end
    end

    describe "revenue calculation methods" do
      before(:each) do
        @merchant_1 = create(:merchant)
        @merchant_2 = create(:merchant)
        @customer_1 = create(:customer)
        @invoice_1 = create(:invoice, customer_id: @customer_1.id)
        @invoice_2 = create(:invoice, customer_id: @customer_1.id)
        @item_1 = create(:item, merchant_id: @merchant_1.id)
        @item_2 = create(:item, merchant_id: @merchant_1.id)
        @item_3 = create(:item, merchant_id: @merchant_2.id)
        @invoice_item_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 1000)
        @invoice_item_2 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1000, unit_price: 100)
        @invoice_item_3 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 50, unit_price: 500)

        @invoice_item_4 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_1.id, quantity: 0, unit_price: 0)
        @invoice_item_5= create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_2.id, quantity: 60, unit_price: 60)
        @invoice_item_6 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 50, unit_price: 40)

        @bulk_1 = create(:bulk_discount, percentage: 10, threshold_quantity: 5, merchant_id: @merchant_1.id)
        @bulk_2 = create(:bulk_discount, percentage: 20, threshold_quantity: 100, merchant_id: @merchant_1.id)
        @bulk_3 = create(:bulk_discount, percentage: 10, threshold_quantity: 25, merchant_id: @merchant_2.id)
      end

      describe "#total_revenue" do
        it "returns the total revenue generated by the invoice for all merchants" do
          expect(@invoice_1.total_revenue).to eq(135000)
          expect(@invoice_2.total_revenue).to eq(5600)
        end
      end

      describe "#total_revenue_for_merchant(merchant_id)" do
        it 'returns the total revenue generated by the invoice for a single merchant' do
          expect(@invoice_1.total_revenue_for_merchant(@merchant_1.id)).to eq(110000)
          expect(@invoice_1.total_revenue_for_merchant(@merchant_2.id)).to eq(25000)
          expect(@invoice_2.total_revenue_for_merchant(@merchant_1.id)).to eq(3600)
          expect(@invoice_2.total_revenue_for_merchant(@merchant_2.id)).to eq(2000)
        end
      end

      describe "#discount_amount" do
        it 'returns the discount for all items with any applicable bulk discounts applied' do
          expect(@invoice_1.discount_amount).to eq(23500)
          expect(@invoice_2.discount_amount).to eq(560)
        end
      end

      describe "#discount_amount_for_merchant(merchant_id)" do
        it 'returns the discount for the merchants items with any applicable bulk discounts applied' do
          expect(@invoice_1.discount_amount_for_merchant(@merchant_1.id)).to eq(21000)
          expect(@invoice_1.discount_amount_for_merchant(@merchant_2.id)).to eq(2500)
          expect(@invoice_2.discount_amount_for_merchant(@merchant_1.id)).to eq(360)
          expect(@invoice_2.discount_amount_for_merchant(@merchant_2.id)).to eq(200)
        end
      end

      describe "#total_discounted_revenue" do
        it 'returns the total discounted revenue generated by the invoice for all merchants' do
          expect(@invoice_1.total_discounted_revenue).to eq(111500)
          expect(@invoice_2.total_discounted_revenue).to eq(5040)
        end
      end

      describe "#total_discounted_revenue_for_merchant(merchant_id)" do
        it 'returns the total discounted revenue generated by the invoice for a single merchant' do
          expect(@invoice_1.total_discounted_revenue_for_merchant(@merchant_1.id)).to eq(89000)
          expect(@invoice_1.total_discounted_revenue_for_merchant(@merchant_2.id)).to eq(22500)
          expect(@invoice_2.total_discounted_revenue_for_merchant(@merchant_1.id)).to eq(3240)
          expect(@invoice_2.total_discounted_revenue_for_merchant(@merchant_2.id)).to eq(1800)
        end
      end
    end
  end
end
