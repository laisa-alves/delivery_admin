class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!

  # GET /buyers/orders
  def index
    if current_user.admin?
      @orders = Order.includes([:buyer, :store, order_items: :product])

    elsif current_user.buyer?
      @orders = Order.includes([:store, :buyer, order_items: :product]).where(buyer: current_user)
    end
  end

  # GET /buyers/orders/1
  def show

  end

  # GET /buyers/orders/new
  def new
    @order = Order.new
    @stores = Store.kept
    @products = Product.kept

    if current_user.admin?
      @buyers = User.kept.where(role: :buyer)
    end

  end

  # GET /buyers/orders/1/edit
  def edit

  end

  # POST /buyers/orders
  def create
    @order = Order.new(order_params)

    if current_user.buyer?
      @order = Order.new(order_params) { |o| o.buyer = current_user }
    end

    if @order.save
      render :create, status: :created
    else
      render json: { errors: @order.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /buyers/orders/1
  def update

  end

  # DELETE /buyers/orders/1
  def destroy

  end

  private

  def order_params
    required = params.require(:order)

    if current_user.admin?
      required.permit(:user_id, :store_id, order_items_attributes: [:product_id, :amount, :price])
    else
      required.permit(:store_id, order_items_attributes: [:product_id, :amount, :price])
    end
  end
end
