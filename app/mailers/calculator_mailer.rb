# app/mailers/calculator_mailer.rb
class CalculatorMailer < ApplicationMailer

  # Remove the default from line here to inherit from ApplicationMailer
  layout "mailer"

  def send_calculation(email, calculation_data)
    @total_overheads = calculation_data[:total_overheads]
    @total_package_cost = calculation_data[:total_package_cost]
    @total_hourly_rate = calculation_data[:total_hourly_rate]

    mail(to: email, subject: 'Your Pricing Calculation Results')
  end
end
