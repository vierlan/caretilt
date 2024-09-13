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
end
