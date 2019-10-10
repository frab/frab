# https://github.com/plataformatec/devise/issues/2341
class FrabDeviseMailer < Devise::Mailer
  default parts_order: ['text/plain', 'text/html']
end
