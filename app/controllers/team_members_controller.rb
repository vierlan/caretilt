class TeamMembersController < ApplicationController
  def new
    @company = current_user.company
    @user = User.new
  end

  def create
    email = params[:email]
    password = Devise.friendly_token.first(8)
    user = User.new(email: email, password: password, password_confirmation: password)
    case current_user.role
    when 'care_provider_super_user'
      user.role = 'care_provider_user'
      user.company = current_user.company
    when 'la_super_user'
      user.role = 'la_user'
      user.local_authority = current_user.local_authority
    when 'caretilt_master_user'
      user.role = 'caretilt_user'
    else
      render status: :forbidden
    end

    if user.save
      UserMailer.with(user: user, password: password).welcome_email.deliver_later
      redirect_to team_members_new_path(current_user), notice: 'Team member added successfully.'
    else
      redirect_to team_members_error_path, notice: 'Failed to add team member.'
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
