class ProductsController < ApplicationController
  skip_forgery_protection only: %i[create update destroy]
  before_action :authenticate!, except: [:public_index]
  before_action :restrict_buyer_access, except: [:public_index]
  before_action :set_store
  before_action :set_products, only: %i[show edit update destroy toggle_active]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /stores/:store_id/products
  def index
    if current_user.seller? || current_user.admin?
      page = params.fetch(:page, 1)
      @products = Product.kept.where(store_id: params[:store_id]).order(:title).page(page)
    end
  end

  def public_index
    if is_buyer?
      page = params.fetch(:page, 1)
      @products = Product.kept.where(active: true, store_id: params[:store_id]).order(:title).page(page)
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # GET /stores/:store_id/products/:id
  def show
  end

  # GET /stores/:store_id/products/new
  def new
    @product = @store.products.build
  end

  # GET /stores/:store_id/products/:id/edit
  def edit; end

  # POST /stores/:store_id/products
  def create
    @product = @store.products.build(product_params)

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: 'Produto criado com sucesso.' }
        format.json { render json: @product, status: :created, location: [@store, @product] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/:store_id/products/:id
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to store_url(@store), notice: 'Produto atualizado com sucesso.' }
        format.json { render json: @product, status: :ok, location: [@store, @product] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/:store_id/products/:id
  def destroy
    @product.discard

    respond_to do |format|
      format.html { redirect_to store_url(@store), notice: 'Product was successfully destroyed.' }
      format.json { render json: { message: 'Your product has been deleted', product: @product } }
    end
  end

  def listing
    redirect_to root_path, notice: 'No permission for you' unless current_user.admin?

    @products = Product.includes(:store)
  end

  def toggle_active
    puts @product
    @product.update(active: !@product.active)
    messase = @product.active ? 'Produto ativado com sucesso.' : 'Produto desativado com sucesso.'
    redirect_to store_path(@store), notice: messase
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_products
    @product = @store.products.kept.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :price, :category, :description, :image)
  end
end
