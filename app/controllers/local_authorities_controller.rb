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
    authorize :local_authority, :edit?
    case current_user.role
    when 'caretilt_master_user', 'caretilt_user'
      @local_authority = LocalAuthority.find(params[:id])
    when 'la_super_user'
      @local_authority = current_user.local_authority
    else
      redirect_to dashboard_index_path(current_user), notice: 'You do not have permission to edit this company.'
    end
  end

  def update
    @local_authority = LocalAuthority.find(params[:id])
    authorize :local_authority, :edit?
    if @local_authority.update(local_authority_params)
      redirect_to local_authorities_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize :local_authority, :delete?
  end

  private

  def set_local_authority
    @local_authority = LocalAuthority.find(params[:id])
  end

  def local_authority_params
    params.require(:local_authority).permit(:name, :email)
  end
end
