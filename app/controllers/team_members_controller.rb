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
      @verified_members = @all_members.not_added
      @team_super_user = @all_members.care_provider_super_user
      @team_users = @all_members.care_provider_user
      @care_homes = @company.care_homes
      @unverified_users = @team_users.added
      @unassigned_users = @verified_members.where(care_home_id: nil)
      @name = @company.name
    elsif current_user.local_authority
      @la = LocalAuthority.find(params[:id])
      @all_members = @la.users
      @verified_members = @all_members.not_added
      @team_super_user = @all_members.la_super_user
      @team_users = @all_members.la_user
      @care_homes = CareHome.all
      @unverified_users = @team_users.added
      @unassigned_users = @verified_members.where(care_home_id: nil)
      @name = @la.name
    else
      @name = 'Caretilt'
    end
  end

  def new
    @company = Company.find(params[:id])
    @user = User.new
  end

  def create
    email = params[:email]
    password = Devise.friendly_token.first(8)
    phone_number = params[:phone_number]
    @member = User.new(email: email, password: password, phone_number: phone_number, status: "inactive")


    case current_user.role
    when 'care_provider_super_user'
      @company = current_user.company
      @member.role = 'care_provider_user'
      @member.company = @company
    when 'la_super_user'
      @la = current_user.local_authority
      @member.role = 'la_user'
      @member.local_authority = @local_authority
    when 'caretilt_master_user'
      @company = Company.find(1)
      @member.role = 'caretilt_user'
      @member.company = @company

    else
      render status: :forbidden
    end

    respond_to do |format|
    if @member.save!
      NotifierMailer.new_account(member: @member).deliver_now
      # format.html { redirect_to team_members_new_path(current_user), notice: 'Team member added successfully. An email has been sent to the new user.' }
      format.turbo_stream { render :create, locals: { member: @member, notice: 'Team member added successfully. An email has been sent to the new user.' } }
        #format.json { render :show, status: :created, location: @member }
      # clear the input field
      # format.js { render js: "document.getElementById('email').value = ''; alert('Team member added successfully. An email has been sent to the new user.');" }

    else

      format.html { render partial: 'form', status: :unprocessable_entity }
      #format.turbo_stream { render :create, status: :unprocessable_entity, locals: { member: @member } }
      format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def verify_member
    @user = User.find(params[:id])
    @company = @user.company || @user.local_authority
  end

  def verify_member_update
    @user = User.find(params[:id])
    @company = @user.company

    # Handle the mark_for_deletion checkbox value as a string
    if params[:user][:mark_for_deletion] == '1'
      flash[:notice] = 'User marked for deletion.'
      @user.destroy
      redirect_to team_company_path(@company, data: { turbo_frame: "main-content" }), notice: 'User has been deleted.'
    elsif @user.update(user_params.except(:mark_for_deletion))
      redirect_to team_company_path(@company, data: { turbo_frame: "main-content" }), notice: 'User has been verified.'
    else
      render :verify_member, status: :unprocessable_entity
    end
  end



  private

  def user_params
    params.require(:user).permit(
      :email, :first_name, :last_name, :care_home_id, :status, :role, :phone_number
    )
  end

  #def check_registration_pin
  #  @user = User.find(params[:id])
  #  @company = Company.find(params[:id])
  #  @pin = params[:pin]
  #  case @pin
  #  when @company.registration_pin
  #    true
  #  when nil
  #    errors.add(:pin, 'Please enter a pin')
  #  else
  #    errors.add(:pin, 'Incorrect pin')
  #  end
  #end



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
