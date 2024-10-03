class BookingEnquiryPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end


  def index?
    true
  end

  def new?
    # is_local_authority_basic?
    true
  end

  def create?
    true
    # new?
  end

  def edit?
    is_local_authority_super?
  end

  def patch?
    edit?
  end

  def delete?
    edit?
  end
end
