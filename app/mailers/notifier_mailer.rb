class NotifierMailer < ApplicationMailer
  def new_account(recipient)
    member = recipient[:member]

    mail(
      to: member.email,
      subject: "Welcome to CareTilt!",
      content_type: "text/html",
      body: "<html><body><h1>Welcome to CareTilt!</h1><p>Thank you for signing up!</p>
      <p>Your account has been created. Please use the following credentials to log in:</p>
      <p>Email: #{member.email}</p>
      <p>Password: #{member.password}</p>
              </body></html>"
    )
  end
  def contact_email(contact_params)
    @contact_params = contact_params
    mail(to: Rails.application.credentials.gmail[:address], subject: 'New Contact Form Submission')
  end


end
