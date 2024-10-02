class UserPolicy < ApplicationPolicy
  class Scope < Scope
    # Define what users can be viewed based on the role of the current user
    def resolve
      if user.caretilt_master_user? || user.caretilt_user? || user.la_super_user? || user.la_user?
        scope.all # Allow these roles to see all users
      elsif user.care_provider_super_user? || user.care_provider_user?
        scope.where(company: user.company) # Restrict users to their own company
      else
        scope.none # No access for other roles
      end
    end
  end

  def index?
    caretilt_admin? || company_basic_edit?
  end

  private

  def caretilt_admin?
    user.caretilt_master_user? || user.caretilt_user?
  end

  def company_basic_edit?
    user.care_provider_super_user? || user.care_provider_user? || user.la_super_user? || user.la_user?
  end
end
