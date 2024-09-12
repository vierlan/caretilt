class NotifierMailer < ApplicationMailer
  def new_account(recipient)

    mail(
      to: recipient,
      subject: "Welcome to CareTilt!",
      content_type: "text/html",
      body: "<html><body><h1>Welcome to CareTilt!</h1><p>Thank you for signing up!</p></body></html>"
    )
  end
end
