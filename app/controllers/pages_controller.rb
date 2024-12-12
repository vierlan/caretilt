class PagesController < ApplicationController

  skip_before_action :authenticate_user!

  def home
  end


  def page
    @page_key = request.path[1..]
    render "pages/#{@page_key}"
  end

  def contact
  end

  def calculator
  end

  def guides
    @blog = BlogPost.published.order(created_at: :desc)
  end

  def show
    @blog_post = BlogPost.find_by(slug: params[:id])
  end

  def search
  end

  def quiz; end

  def pricing
    @month_packages = Package.where(validity: 1, subscription_type: 'company_subscription')
    @packages = []

    @month_packages.each do |package|
      # Handle `data` as either a JSON string or a Ruby Hash
      data = package.data.is_a?(String) ? JSON.parse(package.data) : package.data

      # Ensure `data` is not nil and add the package if `active` is not false
      @packages << package if data.present? && data['active'] != false
    end

  end

  def pricing2
    @annual_packages = Package.where(validity: 12, subscription_type: 'company_subscription')
    @packages = []

    @annual_packages.each do |package|
      # Handle `data` as either a JSON string or a Ruby Hash
      data = package.data.is_a?(String) ? JSON.parse(package.data) : package.data

      # Ensure `data` is not nil and add the package if `active` is not false
      @packages << package if data.present? && data['active'] != false
    end

  end

  def error_not_verified
  end

  def error_team_member
  end

  def test2
    @care_homes = CareHome.where.not(latitude: nil, longitude: nil)
  end

end
