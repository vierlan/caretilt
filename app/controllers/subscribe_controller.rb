class SubscribeController < ApplicationController

  def index
    ab_finished(:cta, reset: false) # reset:false prevents a user from triggering duplicate completions
  end
end
