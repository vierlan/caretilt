class PackagesController < ApplicationController
  before_action :set_packages, only: %i[show edit update destroy]
  def index
    @packages = Package.all
  end

  def show
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(package_params)
    if @package.save
      redirect_to packages_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @package.update(package_params)
      redirect_to packages_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def package_params
    params.require(:package).permit(:name, :description, :price, :duration)
  end


end
