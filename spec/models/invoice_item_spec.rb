require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "relationships" do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
    it { should have_one(:merchant).through(:item) }
    it { should have_one(:customer).through(:invoice) }
    it { should have_many(:transactions).through(:invoice) }
  end

  describe "validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price) }
    it { should validate_presence_of(:status) }
    it { should define_enum_for(:status) }
  end

  describe "instance methods" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @customer_1 = create(:customer)

      @invoice_1 = create(:invoice, customer_id: @customer_1.id)

      @item_1 = create(:item, merchant_id: @merchant_1.id)
      @item_2 = create(:item, merchant_id: @merchant_1.id)
      @item_3 = create(:item, merchant_id: @merchant_1.id)

      @invoice_item_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 1000)
      @invoice_item_2 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1000, unit_price: 100)
      @invoice_item_3 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 2, unit_price: 500)

      @bulk_1 = create(:bulk_discount, percentage: 10, threshold_quantity: 5, merchant_id: @merchant_1.id)
      @bulk_2 = create(:bulk_discount, percentage: 20, threshold_quantity: 100, merchant_id: @merchant_1.id)
      @bulk_3 = create(:bulk_discount, percentage: 15, threshold_quantity: 1, merchant_id: @merchant_2.id)
    end

    describe "#get_discount_id" do
      it 'returns the bulk discount id applied to a given invoice item' do
        expect(@invoice_item_1.get_discount_id).to eq(@bulk_1.id)
        expect(@invoice_item_2.get_discount_id).to eq(@bulk_2.id)
        expect(@invoice_item_3.get_discount_id).to eq(nil)
      end
    end

    describe "#discount_applied?" do
      it 'returns true if a bulk discount has been applied to the invoice item' do
        expect(@invoice_item_1.discount_applied?).to be true
        expect(@invoice_item_2.discount_applied?).to be true
      end

      it 'returns false if a bulk discount has not been applied to the invoice item' do
        expect(@invoice_item_3.discount_applied?).to be false
      end
    end
  end
end
