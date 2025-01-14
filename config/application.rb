require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Caretilt
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # allow cross origin requests
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :patch, :put, :delete]
      end
    end

    # background jobs
    config.active_job.queue_adapter = :delayed

    config.action_mailer.default_url_options = { host: ENV['BASE_URL'] }

    # serve images from asset pipeline in mailers
    config.asset_host = ENV['BASE_URL']

    # customize generators
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.scaffold_controller :scaffold_controller # https://github.com/activeadmin/inherited_resources/issues/195#issuecomment-3556266
      g.jbuilder false # disables json 'jbuilder' views, but still leaves json endpoint format
      g.view_specs false
      g.helper_specs false
      g.routing_specs false
      g.assets false # stylesheets
      g.helper true

      # middleware added by Vierlan added to lib to enable session logging
    end
  end
end
