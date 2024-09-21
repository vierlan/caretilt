class ActivityFeedsController < ApplicationController
  def index
    render plain: session.to_hash
  end
end
