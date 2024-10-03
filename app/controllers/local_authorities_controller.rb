class LocalAuthoritiesController < ApplicationController
  def index
    @local_authorities = policy_scope(LocalAuthority).all

  end

  def new
    authorize @local_authority
  end

  def create
    @local_authority = LocalAuthority.new
    authorize @local_authority
    if @local_authority.save
      redirect_to local_authorities_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @local_authority
  end

  def update
    authorize @local_authority
    if @local_authority.update
      redirect_to local_authorities_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def set_local_authority
    @local_authority = LocalAuthority.find(params[:id])
  end

  def local_authority_params
    params.require(:local_authority).permit(:name)
  end
end
