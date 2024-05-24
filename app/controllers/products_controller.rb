class ProductsController < ApplicationController
  skip_forgery_protection only: %i[create update destroy]
  before_action :authenticate!
  before_action :set_store
  before_action :set_products, only: %i[show edit update destroy]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /stores/:store_id/products
  def index
    respond_to do |format|
      format.json do
        @products = @store.products
      end
    end
  end

  # GET /stores/:store_id/products/:id
  def show
    respond_to do |format|
      format.html
      format.json { render json: @product }
    end
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
        format.html { redirect_to store_products_url(@store, @product), notice: 'Product was successfully created.' }
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
        format.html { redirect_to store_products_url(@store, @product), notice: 'Product was successfully updated.' }
        format.json { render json: @product, status: :ok, location: [@store, @product] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/:store_id/products/:id
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to store_products_url(@store), notice: 'Product was successfully destroyed.' }
      format.json { render json: { message: 'Your product has benn deleted', product: @product } }
    end
  end

  def listing
    redirect_to root_path, notice: 'No permission for you' unless current_user.admin?

    @products = Product.includes(:store)
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_products
    @product = @store.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :price, :description, :image)
  end
end
