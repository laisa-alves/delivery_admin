class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!

  # GET /buyers/orders
  def index
    @orders = orders_for(current_user)

    # if current_user.admin?
    #   @orders = Order.includes([:buyer, :store, order_items: :product])

    # elsif current_user.buyer?
    #   @orders = Order.includes([:store, :buyer, order_items: :product]).where(buyer: current_user)
    # end
  end

  # GET /buyers/orders/1
  def show
    if current_user.admin?
      @order = Order.includes([:buyer, :store, order_items: :product]).find(params[:id])
    else
      @order = Order.where(buyer: current_user).includes([:store, order_items: :product]).find(params[:id])
    end
  end

  # GET /buyers/orders/new
  def new
    @order = Order.new
    @order.order_items.build
    @stores = Store.kept.includes(:products)

    if current_user.admin?
      @buyers = User.kept.where(role: :buyer)
    end

  end

  # GET /buyers/orders/1/edit
  def edit; end

  # POST /buyers/orders
  def create
    @order = Order.new(order_params)
    @order.buyer = current_user if current_user.buyer?

    respond_to do |format|
      if @order.save
        payment_params = {
          number: params[:number],
          valid: params[:valid],
          cvv: params[:cvv].to_i
        }
        process_payment(@order, payment_params)

        format.html {redirect_to order_url(@order), notice: "Pedido criado com sucesso. Processando o pagamento."}
        format.json {render :create, status: :created}
      else
        format.html {render :new, status: :unprocessable_entity}
        format.json {render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def pay
    @order = Order.find(params[:id])

    PaymentJob.perform_later(order: @order, value: @order.total_order_price, number: @order.card_number, valid: @order.card_valid, cvv: @order.card_cvv)

  end

  # PATCH/PUT /buyers/orders/1
  def update; end

  # DELETE /buyers/orders/1
  def destroy; end

  private

  def order_params
    required = params.require(:order)

    if current_user.admin?
      required.permit(:buyer_id, :store_id, order_items_attributes: [:product_id, :amount, :price])
    else
      required.permit(:store_id, order_items_attributes: [:product_id, :amount, :price])
    end
  end

  def orders_for(user)
    if user.admin?
      @orders = Order.includes([:buyer, :store, order_items: :product])

    elsif user.buyer?
      @orders = Order.includes([:store, :buyer, order_items: :product]).where(buyer: user)

    elsif user.seller?
      @orders = Order.includes([:buyer, :store, order_items: :product]).where(store: user.stores, state: ['payment_accepted', 'accepted', 'ready', 'dispatched', 'delivered'])
    end
  end

  def process_payment(order, payment_params)
    PaymentJob.perform_later(
      order: order,
      value: order.total_order_price,
      number: payment_params[:number],
      valid: payment_params[:valid],
      cvv: payment_params[:cvv]
    )
  end
end
