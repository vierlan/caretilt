class CareHomePolicy < ApplicationPolicy
  class Scope < Scope
    # Limit the scope of accessible care homes based on user role
    def resolve
      if user.super_admin? || user.administrator?
        # if user.super_admin? || user.administrator? || user.la_super_user&.local_authority&.has_active_subscription? || user.la_user?
        scope.all # Full access for these roles
      elsif user.la_super_user? || user.la_user?
        scope.joins(:rooms).where(rooms: { vacant: true }).distinct
      elsif user.care_provider_super_user? || user.care_provider_user?
        scope.where(company: user.company) # Limit to their own company's care homes
      else
        scope.none # No access for other roles
      end
    end
  end

  # Example: Authorization for other actions (optional, adjust as needed)
  def show?
    edit? || user.la_super_user? || user.la_user?
  end

  def edit?
    careprovider_basic_edit?
  end

  def update?
    edit?
  end

  def destroy?
    record.company.users.include?(user) && user.care_provider_super_user? || user.super_admin? || user.administrator?
  end

  def index?
  end

  def new?
    is_company_basic?
  end

  def create?
    new?
  end
end
