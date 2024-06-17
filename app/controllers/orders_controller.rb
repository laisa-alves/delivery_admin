class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :set_order, only: %i[show accept_order order_ready_for_pickup dispatch_order deliver_order cancel_order]
  before_action :restrict_buyer_access, only: %i[accept_order order_ready_for_pickup dispatch_order deliver_order cancel_order]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /buyers/orders
  def index
    @orders = orders_for(current_user)
  end

  # GET /buyers/orders/1
  def show; end

  # GET /buyers/orders/new
  def new
    @order = Order.new
    @order.order_items.build
    @stores = Store.kept

    return unless current_user.admin?

    @buyers = User.kept.where(role: :buyer)
  end

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

        format.html { redirect_to order_url(@order), notice: 'Pedido criado com sucesso. Processando o pagamento.' }
        format.json { render :create, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # State machine events
  def accept_order
    return unless @order.accept

    @order.save
    render json: { order_status: @order.state, message: 'Pedido aceito pelo lojista.' }
  end

  def order_ready_for_pickup
    return unless @order.ready_for_pickup

    @order.save
    render json: { order_status: @order.state, message: 'Pedido pronto para ser pego pelo entregador.' }
  end

  def dispatch_order
    return unless @order.dispatch

    @order.save
    render json: { order_status: @order.state, message: 'Pedido em rota de entrega.' }
  end

  def deliver_order
    return unless @order.deliver

    @order.save
    render json: { order_status: @order.state, message: 'Pedido entregue.' }
  end

  def cancel_order
    return unless @order.cancel

    @order.save
    render json: { order_status: @order.state, message: 'Pedido cancelado.' }
  end

  # def pay
  #   @order = Order.find(params[:id])

  #   PaymentJob.perform_later(order: @order, value: @order.total_order_price, number: @order.card_number, valid: @order.card_valid, cvv: @order.card_cvv)

  # end

  private

  def set_order
    @order = if current_user.admin?
               Order.includes([:store, { order_items: :product }]).find(params[:id])
             elsif current_user.seller?
               Order.where(store: current_user.stores).includes([:store, { order_items: :product }]).find(params[:id])
             elsif current_user.buyer?
               Order.where(buyer: current_user).includes([:store, { order_items: :product }]).find(params[:id])
             end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Pedido não encontrado.' }
      format.json { render json: { error: e.message }, status: :not_found }
    end
  end

  def order_params
    required = params.require(:order)

    if current_user.admin?
      required.permit(:buyer_id, :store_id, order_items_attributes: %i[product_id amount price])
    else
      required.permit(:store_id, order_items_attributes: %i[product_id amount price])
    end
  end

  def orders_for(user)
    if user.admin?
      @orders = Order.includes([:buyer, :store, { order_items: :product }])

    elsif user.buyer?
      @orders = Order.includes([:store, :buyer, { order_items: :product }]).where(buyer: user)

    elsif user.seller?
      @orders = Order.includes([:buyer, :store, { order_items: :product }]).where(store: user.stores,
                                                                                  state: %w[
                                                                                    payment_accepted accepted ready dispatched delivered canceled
                                                                                  ])
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

  # Rescue methods
  def not_authorized(_e)
    render json: { message: 'Usuário não autorizado!' }, status: 401
  end
end
