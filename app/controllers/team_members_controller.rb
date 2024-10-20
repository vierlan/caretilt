class TeamMembersController < ApplicationController


  def index
    #Pundit Logic for future reference.

    #Index in pundit needs a collection of objects for its policy SCOPE. We have no team member model.
    # Opt 1. Either rename index -> all (and feed it no object)
    # Opt 2. We feed in a policy scope (doesn't have to be used, just done to get rid of the policy scope required error)
    @all_members = policy_scope(User, policy_scope_class: TeamMemberPolicy::Scope)
    authorize :team_member, :index?

    @user = User.new

    # Authorize the index action itself
    # authorize :team_member, :index?
    if current_user.company
      @company = Company.find(params[:id])
      @all_members = @company.users
      @verified_members = @all_members.verified
      @care_homes = @company.care_homes
      @unverified_users = @all_members.inactive
      @unassigned_users = @verified_members.where(care_home_id: nil)
      @name = @company.name
    elsif current_user.local_authority
      @local_authority = LocalAuthority.find(params[:id])
      @all_members = @local_authority.users
      @verified_members = @all_members.verified
      @care_homes = CareHome.all
      @unverified_users = @all_members.inactive
      @unassigned_users = @verified_members.where(care_home_id: nil)
      @name = @local_authority.name
    end
  end

  def new
    @user = User.new

  end

  def create
    email = params[:email]
    password = Devise.friendly_token.first(8) # "123123"
    phone_number = params[:phone_number]
    @member = User.new(email: email, password: password, phone_number: phone_number, status: "inactive")


    case current_user.role
    when 'care_provider_super_user'
      @company = current_user.company
      @member.role = 'care_provider_user'
      @member.company = @company
    when 'la_super_user'
      @local_authority = current_user.local_authority
      @member.role = 'la_user'
      @member.local_authority = @local_authority
    when 'caretilt_master_user' || 'caretilt_user'
      @company = current_user.company || Company.find(1)
      @member.role = 'caretilt_user'
      @member.company = @company
    else
      render status: :forbidden
    end

    respond_to do |format|
    if @member.save!
      # NotifierMailer.new_account(member: @member).deliver_now
      format.turbo_stream { render :create, locals: { member: @member, notice: 'Team member added successfully. An email has been sent to the new user.' } }
      format.html {
        redirect_to current_user.la_super_user? ?
        team_local_authority_path(@local_authority) :
        team_company_path(@company),
        data: {turbo_frame: "main-content"},
        notice: 'Team member added successfully. An email has been sent to the new user.'
      }

      #redirect_to current_user.la_super_user? ? team_local_authority_path(@local_authority) : team_company_path(@company), data: {turbo_frame: "main-content"}, notice: 'Team member added successfully. An email has been sent to the new user.'
    else

      format.html { render partial: 'form', status: :unprocessable_entity }
      format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def verify_member
    @user = current_user
    @member = User.find(params[:id])
    @company = current_user.company if current_user.company
    @local_authority = current_user.local_authority if current_user.local_authority
  end

  def verify_member_update
    @user = current_user
    @member = User.find(params[:id])
    @company = @user.company if @user.company
    @local_authority = @user.local_authority if @user.local_authority

    # Handle the mark_for_deletion checkbox value as a string
    if params[:user][:mark_for_deletion] == '1'
      flash[:notice] = 'User marked for deletion.'
      @member.destroy
      redirect_to current_user.la_super_user? ?
        team_local_authority_path(@local_authority) :
        team_company_path(@company),
        data: {turbo_frame: "main-content"}, notice: 'User has been deleted.'
    elsif @member.update!(user_params.except(:mark_for_deletion))
      redirect_to current_user.la_super_user? ?
        team_local_authority_path(@local_authority) :
        team_company_path(@company),
        data: {turbo_frame: "main-content"}, notice: 'User Saved'
    else
      render :verify_member, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :first_name, :last_name, :care_home_id, :status, :role, :phone_number, :mark_for_deletion
    )
  end

  def make_user_inactive
    @user = User.find(params[:id])
    @company = Company.find(params[:id])
    if @users.update(status: 3)
      redirect_to team_members_index_path(current_user), notice: 'User has been made inactive.'
    else
      redirect_to team_members_index_path(current_user), alert: 'Error making user inactive.'
    end
  end

  def error; end
end
