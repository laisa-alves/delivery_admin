class StoresController < ApplicationController
  skip_forgery_protection only: %i[create update destroy]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy restore ]
  rescue_from User::InvalidToken, with: :not_authorized


  # GET /stores or /stores.json
  def index
    if current_user.admin?
      @stores = Store.kept.includes([:user])
      @stores_by_user = Store.kept.includes([:user]).all.group_by(&:user)
    else
      @stores = Store.kept.where(user: current_user)
    end
  end

  # GET /stores/1 or /stores/1.json
  def show
    if current_user.admin?
      @stores = Store.includes([image_attachment: :blob])
    else
      @stores = Store.where(user: current_user).includes([image_attachment: :blob])
    end
  end

  # GET /stores/new
  def new
    @store = Store.new

    if current_user.admin?
      @sellers = User.where(role: :seller)
    end
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params)

    # Se current_user não for admin cria a loja para pertencer ao current_user
    if !current_user.admin?
      @store.user = current_user
    end

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1 or /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to store_url(@store), notice: "Store was successfully updated." }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1 or /stores/1.json
  def destroy
    @store.discard

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully removed." }
      format.json { render json: { message: 'Your store has been deleted' } }
    end
  end

  def discarded
    if current_user.admin?
      @stores = Store.discarded.includes([:user])
      @stores_by_user = Store.discarded.includes([:user]).all.group_by(&:user)
    else
      @stores = Store.discarded.where(user: current_user)
    end
  end

  def restore
    @store.undiscard!
    redirect_to stores_path, notice: 'Loja restaurada com sucesso'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def store_params
      required = params.require(:store)

      # Se usuário é admin permite enviar o campo de usuário (dono da loja) além do nome
      if current_user.admin?
        required.permit(:name, :user_id, :image)
      else
        required.permit(:name, :image)
      end
    end

    def not_authorized(e)
      render json: {message: "Nope!"}, status:401
    end
end
