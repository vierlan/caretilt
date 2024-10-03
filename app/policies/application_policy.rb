# frozen_string_literal: true
# Main policies are controlled here.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  def caretilt_admin?
    user.caretilt_master_user? || user.caretilt_user?
  end

  def local_authority_basic_edit?
  end

  def local_authority_super_edit?
  end

  def careprovider_basic_edit?
    record.company.users.include?(user) || user.caretilt_master_user? || user.caretilt_user?
  end

  def careprovider_super_edit?
    record.company.users.include?(user) && user.care_provider_super_user? || user.caretilt_master_user? || user.caretilt_user?
  end

  def company_basic_edit?
    record.users.include?(user) || user.caretilt_master_user? || user.caretilt_user?
  end
  
  def company_super_edit?
    record.users.include?(user) && user.care_provider_super_user? || user.caretilt_master_user? || user.caretilt_user?
  end

  # Careprovider admin permission

  def is_company_admin?
    user.care_provider_super_user? || user.care_provider_super_user? || user.caretilt_master_user?
  end

  def is_company_basic?
    user.care_provider_user? || user.care_provider_super_user? || user.care_provider_super_user? || user.caretilt_master_user?
  end

  def is_local_authority_basic?
     user.la_user? || user.la_super_user?|| user.care_provider_super_user? || user.caretilt_master_user?
  end

  def is_local_authority_admin?
    user.la_super_user?|| user.care_provider_super_user? || user.caretilt_master_user?
  end

end
