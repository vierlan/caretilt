class CareHomePolicy < ApplicationPolicy
  class Scope < Scope
    # Limit the scope of accessible care homes based on user role
    def resolve
      if user.caretilt_master_user? || user.caretilt_user? || user.la_super_user? || user.la_user?
      # if user.caretilt_master_user? || user.caretilt_user? || user.la_super_user&.local_authority&.has_active_subscription? || user.la_user?
        scope.all # Full access for these roles
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

  def delete?
    record.company.users.include?(user) && user.care_provider_super_user? || user.caretilt_master_user? || user.caretilt_user?
  end
end
