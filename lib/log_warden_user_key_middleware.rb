# lib/log_warden_user_key_middleware.rb
# added by Vierlan to log warden.user.user.key check config/application.rb
class LogWardenUserKeyMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    session = request.session

    if session["warden.user.user.key"]
      Rails.logger.info "warden.user.user.key: #{session["warden.user.user.key"].inspect}"
    else
      Rails.logger.info "warden.user.user.key not found in session"
    end

    @app.call(env)
  end
end
