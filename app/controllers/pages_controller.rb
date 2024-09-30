class PagesController < ApplicationController
#skip_before_action :authenticate_user!, except: [:logout]
  def home
    # @current_user = current_user
  end

  def logout
    reset_session
    sign_out(current_user)
    redirect_to home_path
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

  def test2
    @care_homes = CareHome.where.not(latitude: nil, longitude: nil)
  end
end
