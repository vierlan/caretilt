# app/mailers/calculator_mailer.rb
class CalculatorMailer < ApplicationMailer
    # Remove the default from line here to inherit from ApplicationMailer

    layout "mailer"
  
    def send_calculation(email, calculation_data)
      @calculation_data = calculation_data
      mail(to: email, subject: 'Your Pricing Calculation Results')
    end
  end
  