class Merchant::BulkDiscountsController < ApplicationController
  before_action :find_merchant, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :find_discount, only: [:show, :edit, :update, :destroy]

  def index
    @holidays = HolidaySearch.new.top_holidays(3)
  end

  def new
  end

  def create
    @discount = BulkDiscount.new(bulk_discount_params.merge(merchant_id: @merchant.id))
    if @discount.valid? && !invalid_discount?
      @discount.save
      redirect_to merchant_bulk_discounts_path(@merchant), notice: "Discount successfully added!"
    elsif @discount.valid? && invalid_discount?
      flash.now[:alert] = "Try again! You cannot create a discount that will not be applied."
      render :new
    else
      flash.now[:alert] = "Error: #{error_message(@discount.errors)}"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if attributes_changed?
      check_edit_validity
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

  def invalid_discount?
    best_percentage = @merchant.find_best_discount(bulk_discount_params[:threshold_quantity])
    bulk_discount_params[:percentage].to_i < best_percentage
  end

  def attributes_changed?
    (bulk_discount_params[:percentage].to_i != @discount.percentage) ||
    (bulk_discount_params[:threshold_quantity].to_i != @discount.threshold_quantity)
  end

  def check_edit_validity
    if invalid_discount?
      flash.now[:alert] = "Try again! The attempted update would make this discount invalid."
      render :edit
    else
      @discount.update(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, @discount), notice: "Discount successfully updated!"
    end
  end
end
