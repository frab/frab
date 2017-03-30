require 'active_support/concern'

module HasTicketServer
  extend ActiveSupport::Concern

  included do
    TICKET_TYPES = %w(otrs rt redmine integrated).freeze

    has_one :ticket_server, dependent: :destroy
    accepts_nested_attributes_for :ticket_server
  end

  def ticket_server_enabled?
    return false if ticket_type.nil?
    return false if ticket_type == 'integrated'
    true
  end
end
