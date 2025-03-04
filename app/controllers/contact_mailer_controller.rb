class ContactMailerController < ApplicationController

  skip_before_action :authenticate_user!
  
  def new
    authorize :contact_mailer, :new?
  end

  def create
    contact_params = params.require(:contact).permit(:first_name, :last_name, :email, :phone_number, :message)
    NotifierMailer.contact_email(contact_params).deliver_now
    redirect_to contact_path, notice: 'Your message has been sent successfully.'
  end

  private

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone_number, :message)
  end
end
