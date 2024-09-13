class TeamMembersController < ApplicationController
  def new
    @company = current_user.company
    @user = User.new
  end

  def index
    @user = User.new
    @members = current_user.company.users
    @team_members = @members.where(verified: true)
    @company = current_user.company
    @team_super_user = @team_members.find_by(role: 'care_provider_super_user')
    @team_users = @team_members.where(role: 'care_provider_user')
    @care_homes = @company.care_homes
    @unverified_users = @team_users.where(verified: false)
    @unassigned_users = @team_users.where(care_home_id: nil)
  end

  def create
    email = params[:email]
    password = Devise.friendly_token.first(8)
    @member = User.new(email: email, password: password)
    case current_user.role
    when 'care_provider_super_user'
      @member.role = 'care_provider_user'
      @member.company = current_user.company
    when 'la_super_user'
      @member.role = 'la_user'
      @member.local_authority = current_user.local_authority
    when 'caretilt_master_user'
      @member.role = 'caretilt_user'
    else
      render status: :forbidden
    end

    respond_to do |format|
      if @member.save
        NotifierMailer.new_account(member: @member).deliver_now
        format.html { redirect_to team_members_new_path(current_user), notice: 'Team member added successfully. An email has been sent to the new user.' }
        format.turbo_stream { render :create, locals: { member: @member, notice: 'Team member added successfully. An email has been sent to the new user.' } }
        format.json { render :show, status: :created, location: @member }
        # clear the input field
        format.js { render js: "document.getElementById('email').value = ''; alert('Team member added successfully. An email has been sent to the new user.');" }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :create, status: :unprocessable_entity, locals: { member: @member } }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def verify
    verify_user = User.find(params[:id])
    if current_user.role == 'care_provider_super_user' && verify_user.company == current_user.company
      verify_user.update(verified: true)
    elsif current_user.role == 'la_super_user' && verify_user.local_authority == current_user.local_authority
      verify_user.update(verified: true)
    else
      render status: :forbidden
    end
  end

  def unverified
    @company = current_user.company
    @users = @company.users.where(verified: false)
  end

  def error; end
end
