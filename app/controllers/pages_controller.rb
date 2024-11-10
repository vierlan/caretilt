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
    @blog_posts = BlogPost.published.order(created_at: :asc)
  end

  def search
  end

  def quiz; end

  def pricing
    @packages = Package.where(validity: 1, subscription_type: 'company_subscription')
  end

  def pricing2
    @packages = Package.where(validity: 12, subscription_type: 'company_subscription')
  end

  def error_not_verified
  end

  def error_team_member
  end

  def test2
    @care_homes = CareHome.where.not(latitude: nil, longitude: nil)
  end

end
