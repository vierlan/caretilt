class PackagePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
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

  def show?
    false
  end

  def create?
    false
  end
end