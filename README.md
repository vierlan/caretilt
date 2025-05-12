# Caretilt
a Rails 7 template.


**CareTilt features**
* rich text blog CMS
* embedded subscription payment portal via [Stripe Checkout](https://docs.stripe.com/payments/accept-a-payment?platform=web&ui=embedded-form)
* built-in referral marketing via [Rewardful](https://www.rewardful.com/?via=speedrail)
* admin panel with Tailwind CSS via [Active Admin](https://github.com/activeadmin/activeadmin/)
* user authentication via [Devise](https://github.com/plataformatec/devise)
* A/B testing with [Split](https://github.com/splitrb/split/)
* design via [Flowbite](https://flowbite.com/) and [Tailwind UI](https://tailwindui.com/)
* SEO toolbelt via [metamagic](https://github.com/lassebunk/metamagic)
* responsive and mobile friendly navigation
* beautiful code coverage GUI via [SimpleCov](https://github.com/simplecov-ruby/simplecov) and [TailwindCov](https://github.com/chiefpansancolt/simplecov-tailwindcss)
* rename your app in 1 command with [Rename](https://github.com/get/Rename)
* debugging with [Better Errors](https://github.com/charliesome/better_errors)
* production-ready DB with Postgres
* easy API requests with [HTTParty](https://github.com/jnunemaker/httparty)
* script tag GUI (for Google Analytics, etc)
* testing suite via [RSpec](https://github.com/rspec/rspec-rails/)
* cron job task scheduler (`lib/tasks/scheduler.rake`)
* random data generation with [Faker](https://github.com/faker-ruby/faker)
* Heroku <> Cloudflare HTTPS via `lib/cloudflare_proxy.rb`
* background job queue via [Delayed](https://rubygems.org/gems/delayed)
* interactive charts via [Chartkick](https://chartkick.com)
* automated testing via GitHub actions + PR status check
* Rubocop for code style enforcement and linting auto-fixes

## Development
```sh
bin/dev # uses foreman to boot server, frontend, and bg job queue
```


## Testing
```sh
# headless
bundle exec rspec # run all tests inside spec/
bundle exec rspec spec/dir_name # run all tests inside given directory

# headed (in a real browser)
HEADED=TRUE bundle exec rspec
```

## Code Quality

clean code keeps projects manageable as they grow in complexity.

```sh
rubocop # checks your code against Ruby styling standards and calls out issues
rubocop -A # automatically fixes issues, can lead to false negatives
rubocop -a # automatically fixes "safe" issues, less aggressive than -A (uppercase)
```

**Rubocop is an optional feature**, however it runs automatically during GitHub CI checks. if you don't want to enforce the Rubocop style guide, simply disable the `Rubocop Check` step inside `ci.yml`.

Overview

Care Tilt is a web application designed to streamline the management of care home services. It integrates with multiple third-party APIs for enhanced functionality, including Stripe for payments, Google APIs for geolocation and maps, Twilio for two-factor authentication (2FA), and AWS S3 for handling image and media uploads. Turbo enhances the user experience by enabling fast updates without full-page reloads, and Tailwind CSS is used for styling. Stimulus handles JavaScript interactivity.


Care Tilt handles two main entities: Companies and Local Authorities. It accommodates six distinct user levels and features a polymorphic subscription system to support various subscription types tailored to these entities.


Table of Contents

Technology Stack
Entities and Roles
Key Features
Setup and Configuration
Development Notes
Important Considerations
Suggestions for improvements for future phases

1. Technology Stack
Backend

Framework: Ruby on Rails 7.2.1
Language: Ruby 3.2.2
Authentication: Devise
Authorization: Pundit

Frontend

CSS Framework: Tailwind CSS
JavaScript Framework: Stimulus

Production Server

Heroku: app.caretilt.co.uk

Database

Primary: PostgreSQL

File Storage

Media Handling: AWS S3

Core Features

User Authentication:
Handled by Devise.
Two-factor authentication (2FA) via Twilio for enhanced security.
Authorization:
Role-based access control implemented using Pundit policies.
Roles include admin, care home manager, and standard users.
Payment Processing:
Stripe integration for handling subscriptions and payments.
Custom plans and features can be managed through Stripe's dashboard.
Care Home Management:
Add and manage care homes.
Manage rooms, availability, and pricing.
Google APIs:
Address autocomplete and geocoding for care homes.
Display care homes on maps.


             Core Functionalities

User Management:
User roles and permissions are managed using Devise and Pundit.
Subscriptions:
Subscriptions are polymorphic and linked to either a Company or Local Authority.
Dashboard:
Uses Turbo for smooth and dynamic updates to the user interface.

Key Concepts

Authentication Flow:
Devise handles user sign-in and sign-up.
Twilio sends 2FA codes upon login.
Authorization Flow:
Pundit policies restrict actions based on user roles.
Subscription Management:
Stripe processes payments and renewals.
Address and Location Handling:
Google APIs ensure accurate geocoding and autocomplete.


2. Entities and Roles
Entities

Company
Represents care providers.
Care Tilt is always set as Company.first.
Local Authority (LA)
Represents local government bodies or authorities.

Roles

The application has six user levels defined as an enum in the User model:

ruby
Copy code
enum :role, {  
  undefined: 0,  
  super_admin: 1,  
  administrator: 2,  
  care_provider_super_user: 3,  
  care_provider_user: 4,  
  la_super_user: 5,  
  la_user: 6  
}, _default: :undefined  


Undefined: Set as a default and acts as a fallback to prevent unauthorized permissions should correct assignment fail.
super_admin: Has complete system control.
administrator: Manages users and configurations at a high level.
care_provider_super_user and care_provider_user: Represent users under the Company entity.
la_super_user and la_user: Represent users under the Local Authority entity.

3. Key Features

Polymorphic Subscriptions: Subscriptions are polymorphic, allowing them to be assigned to either Companies or Local Authorities, catering to diverse subscription requirements.
Geolocation and Maps: Integration with Google APIs for locating and mapping care homes.
Two-Factor Authentication (2FA): Implemented using Twilio for enhanced security.
Media Uploads: All images and files are securely uploaded to AWS S3.
Turbo-Driven Updates: Uses Turbo for seamless and fast UI updates without full page reloads.

Code Architecture

Models:
Represent database tables.
Example: User, CareHome, Room.
Controllers:
Handle HTTP requests and responses.
Example: CareHomesController, RoomsController.
Services:
Encapsulate business logic for external services.
Example: StripeService, TwilioService.
Policies:
Define user permissions for specific actions.
Example: CareHomePolicy.
Views:
Render HTML templates for pages.
Example: app/views/care_homes/index.html.erb.

4. Third-Party Integrations

Stripe: Handles subscription billing and payment processing.
Google APIs: For geolocation and maps services.
Twilio: Provides two-factor authentication (2FA) for user accounts.
AWS S3: Used for image and media uploads.

Environment Variables

Stripe:
STRIPE_API_KEY
STRIPE_PUBLISHABLE_KEY
STRIPE_WEBHOOK_SECRET
Google:
GOOGLE_API_KEY
Twilio:
TWILIO_ACCOUNT_SID
TWILIO_AUTH_TOKEN
TWILIO_PHONE_NUMBER
App Config:
BASE_URL (e.g., https://your-app-domain.com)
DEVISE_SECRET_KEY

Email Configuration

Emails are handled by Hostinger using SMTP:

ruby
Copy code
config.action_mailer.delivery_method = :smtp  
config.action_mailer.default_url_options = { host: 'app.caretilt.co.uk', protocol: 'https' }

  config.action_mailer.smtp_settings = {
    address: "smtp.hostinger.com",
    port: 587,
    user_name: Rails.application.credentials.gmail[:address],
    password: Rails.application.credentials.gmail[:password],
    authentication: "plain",
    enable_starttls_auto: true
  }

5. Development Notes
Stimulus Controllers

Stimulus is used to manage front-end interactivity. Ensure all controllers are placed in the appropriate directory (app/javascript/controllers) and adhere to the naming conventions.

Database Seeding

A CSV file is used to populate Local Authority names.


If the database is dropped, re-run rails local_authorities:import to restore this data.
The seed script can be found in db/seeds.rb.  This should be adjusted as needed before running.

6. Important Considerations

Care Tilt Setup:
Care Tilt must always be set as Company.first.
Role Fallback:
The undefined role prevents accidentally assigning unintended permissions during user creation or error states.
Media Handling:
Ensure AWS S3 credentials are correctly configured in the Rails credentials or environment variables.


7. Suggestions for improvements in future phases
Database backup script
Webhooks for Stripe.  At present the Dashboard Controller has a before_action to check the subscription/payment details on stripe every time someone enters the Dashboard.  At this level, it works and prevents/grants access according to the latest information on Stripe but is not resource friendly and makes far too many unnecessary API calls to Stripe. Webhooks is set up mostly but needs refining.  Event triggered methods would be the ideal way to implement subscription based access (i.e. invoice.paid then triggers finds the entity and updates the subscription, invoice.failed triggers an email)
Adding more activities to the activity feed.  Using Turbo to update so new feeds are dynamically injected in real time instead of on refresh.
Admin can create and have full control of Companies/Local Authorities, instead of having to create a new Superuser account for each entity. (At present they can already have a lot of scope, but the app was designed around the fact that entities are fully responsible for their own listings and staff.
 Improvements to the Care Home search parameters and filters.  Implementing sort_by?
Using- Adding more data for users and perhaps an avatar?
Company/Local Authority details - Adding more data for the Company/Local Authority.
2 way messaging system (using Turbo for real time updating) between entities.
Charts graphs data that show the care provider superuser stats (how many vacancy filled, average void time by care home)

The below would be even further in the future if the company were to expand, let's make the app into a fully fledged management system:

 Employee management: Rota, clock in and out, holiday management.
Calendar: for important company events, reminders of when Service Users will move in/out.


Contact & Support

For any issues or questions:


Developer: lananhnguyen@live.co.uk
Github: https://github.com/vierlan/caretilt

