class DashboardPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # class Scope < ApplicationPolicy::Scope
  #   # This is used for INDEX ONLY, cause index takes MULTIPLE items.
  #   # NOTE: Be explicit about which records you allow access to!
  #   def resolve
  #     if user.caretilt_master_user? || user.caretilt_user? || user.la_super_user? || user.la_user?
  #       # These roles can see all records
  #       scope.all
  #     elsif user.care_provider_super_user? || user.care_provider_user?
  #       # Care provider users can only see items associated with their company or organization
  #       scope.where(company: user.company)
  #     else
  #       # If role is undefined or something else, return an empty result (or raise an error)
  #       scope.none
  #     end
  #   end
  # end

end
