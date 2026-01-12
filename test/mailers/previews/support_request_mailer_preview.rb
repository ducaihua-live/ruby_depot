# Preview all emails at http://localhost:3000/rails/mailers/support_request_mailer
class SupportRequestMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/support_request_mailer/response
  def response
    SupportRequestMailer.response
  end
end
