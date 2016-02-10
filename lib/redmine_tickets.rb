module RedmineTickets
  #
  # Rails Views
  #
  module Helper
    def self.get_ticket_view_url(conference, remote_id)
      return if conference.ticket_server.nil?
      uri = URI.parse(conference.ticket_server.url)
      uri.path += "issues/#{remote_id}"
      uri.to_s
    end
  end

  #
  # RT Server
  #
  class RedmineAdapter
    require 'uri'
    require 'active_resource'

    def initialize(c, l)
      @conference = c
      @logger = l
      @test_only = false
    end
    attr_accessor :test_only

    class Issue < ActiveResource::Base
      self.include_root_in_json = true

      class << self
        def configure(&block)
          instance_eval &block
        end

        def key=(val)
          self.headers['X-Redmine-API-Key'] = val
        end
      end
    end

    def create_issue(args)
      ticket_server = @conference.ticket_server

      Issue.configure do
        self.site = ticket_server.url
        self.user = ticket_server.user
        self.key = ticket_server.password
      end

      issue = Issue.new(subject: args[:title],
                        description: "#{args[:event_url]}\nTicket created by #{args[:owner_email]}",
                        project_id: ticket_server.queue)

      if @test_only
        @logger.info @uri.path
        @logger.info "content => #{args}"
        return
      end

      issue.save
      issue.id
    end

  end

  def self.create_remote_ticket(args = {})
    args.reverse_update(body: '', test_only: false)
    @conference = args[:conference]

    ticket_system = RedmineAdapter.new(@conference, Rails.logger)
    ticket_system.test_only = args[:test_only]
    ticket_system.create_issue(args)
  end

  def self.create_ticket_title(prefix, event)
    "#{prefix} '#{event.title.truncate(30)}'"
  end

  def self.create_ticket_requestors(people)
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.delete!(',')
      { name: name, email: p.email }
    }
  end

end
