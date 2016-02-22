class RedmineTicketServerAdapter < TicketServerAdapter
  require 'uri'
  require 'active_resource'

  private

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

  public

  def get_ticket_view_url(remote_id)
    uri = URI.parse(@server.url)
    uri.path += "issues/#{remote_id}"
    uri.to_s
  end

  def create_remote_ticket(args)

    server = @server

    Issue.configure do
      self.site = server.url
      self.user = server.user
      self.key = server.password
    end

    issue = Issue.new(subject: args[:title],
                      description: "#{args[:frab_url]}\nTicket created by #{args[:owner_email]}",
                      project_id: server.queue)

    if @test_only
      @logger.info @uri.path
      @logger.info "content => #{args}"
      return
    end

    issue.save
    issue.id
  end


end