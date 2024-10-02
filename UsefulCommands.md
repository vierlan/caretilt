Check env variable:
ENV['TWILIO_VERIFICATION_SID']

Import local authorities from script:
rails local_authorities:import

Drop db and recreate seeds:
rails db:drop db:create db:migrate local_authorities:import db:seed

Rspec tests:
bundle exec rspec spec/models/care_home_spec.rb    
bundle exec rspec spec/models/room_spec.rb   