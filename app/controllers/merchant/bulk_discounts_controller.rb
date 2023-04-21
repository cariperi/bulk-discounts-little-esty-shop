class Merchant::BulkDiscountsController < ApplicationController
  before_action :find_merchant, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :find_discount, only: [:show, :edit, :update, :destroy]
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
  end

  def edit
  end

  def update
    if attributes_changed?
      @discount.update(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, @discount), notice: "Discount successfully updated!"
    else
      flash.now[:alert] = "Error: You must update at least 1 field to continue."
      render :edit
    end
  end

  def destroy
    @discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant), notice: "Discount successfully deleted!"
  end

  private
  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_discount
    @discount = BulkDiscount.find(params[:id])
  end

  def bulk_discount_params
    params.require(:bulk_discount).permit(:percentage, :threshold_quantity)
  end

  def attributes_changed?
    (bulk_discount_params[:percentage] != @discount.percentage.to_s) ||
    (bulk_discount_params[:threshold_quantity] != @discount.threshold_quantity.to_s)
  end
end
