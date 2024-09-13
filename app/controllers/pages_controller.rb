class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:logout]

  def home
    # @current_user = current_user
  end

  def logout
    sign_out(current_user)
    redirect_to root_path
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
  end

  def search
  end

  def quiz; end
end
