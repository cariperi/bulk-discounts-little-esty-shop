class Merchant::BulkDiscountsController < ApplicationController
  before_action :find_merchant, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  def index
  end

  def new
  end

  def create
    discount = BulkDiscount.new(bulk_discount_params.merge(merchant_id: @merchant.id))
    if discount.save
      redirect_to merchant_bulk_discounts_path(@merchant), notice: "Discount successfully added!"
    else
      flash.now[:alert] = "Error: #{error_message(discount.errors)}"
      render :new
    end
  end

  def show
    @discount = BulkDiscount.find(params[:id])
  end

  def destroy
    discount = BulkDiscount.find(params[:id])
    discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant), notice: "Discount successfully deleted!"
  end

  private
  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def bulk_discount_params
    params.require(:bulk_discount).permit(:percentage, :threshold_quantity)
  end
end
