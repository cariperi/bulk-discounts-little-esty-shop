require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:items).through(:merchant) }
  end

  describe "validations" do
    it { should validate_presence_of(:threshold_quantity) }
    it { should validate_presence_of(:percentage) }
    it { should validate_numericality_of(:threshold_quantity) }
    it { should validate_numericality_of(:percentage) }
  end
end
