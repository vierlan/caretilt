class LocalAuthoritiesController < ApplicationController
  def index
    @local_authorities = LocalAuthority.all
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
    true
  end

  def update
  end

  def destroy
  end
end
