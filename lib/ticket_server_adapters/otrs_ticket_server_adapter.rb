class OTRSTicketServerAdapter < TicketServerAdapter
  require 'uri'
  require 'net/http'

  def get_ticket_view_url(remote_id)
    return unless remote_id.is_a? Fixnum
    uri = URI.parse(@server.url)
    uri.path += 'index.pl'
    uri.query = "Action=AgentTicketZoom;TicketID=#{remote_id}"
    uri.to_s
  end

  #
  # connect to a remote ticket system and return remote_id
  #
  def create_remote_ticket(args = {})
    args.reverse_update(body: '', test_only: false)
    @test_only = args[:test_only]

    # FIXME iphonehandle no longer whitelists UserObject in Kernel/Config/Files/iPhone.xml
    # data = otrs.connect( 'UserObject', 'GetUserData', { User: @server.user })
    # user_data = Hash[*data]
    data = connect('CustomObject', 'VersionGet', UserID: 1)

    # data = connect( 'UserObject', 'GetUserData', { UserEmail: args[:owner_email] })
    # owner_data = Hash[*data]

    from = args[:owner_email]
    unless args[:requestors].empty?
      from = args[:requestors].collect { |r| "#{r[:name]} <#{r[:email]}>" }.join(', ')
    end

    remote_ticket_id = connect('TicketObject', 'TicketCreate',      Title: args[:title],
                                                                    Queue: @server.queue,
                                                                    Lock: 'unlock',
                                                                    Priority: '3 normal',
                                                                    State: 'new',
                                                                    CustomerUser: from,
                                                                    UserID: 1,
                                                                    OwnerID: 1).first

    remote_article_id = connect('TicketObject', 'ArticleCreate',    TicketID: remote_ticket_id,
                                                                    ArticleType: 'webrequest',
                                                                    SenderType: 'customer',
                                                                    HistoryType: 'WebRequestCustomer',
                                                                    HistoryComment: 'created from frab',
                                                                    From: from,
                                                                    Subject: args[:title],
                                                                    ContentType: 'text/plain; charset=ISO-8859-1',
                                                                    Body: args[:body],
                                                                    UserID: 1,
                                                                    Loop: 0).first

    remote_ticket_id
  end

  private

  def connect(object, method, data)
    # see https://github.com/cpuguy83/rails_otrs
    uri = URI(@server.url)
    uri.path += 'json.pl'

    # credentials
    user = URI.encode @server.user
    password = URI.encode @server.password
    uri.query = "User=#{user}"
    uri.query += "&Password=#{password}"

    # otrs api
    uri.query += "&Object=#{object}"
    uri.query += "&Method=#{method}"
    data = URI.encode(data.to_json)
    data = URI.escape(data, '=\',\\/+-&?#.;')
    uri.query += "&Data=#{data}"

    if $DEBUG
      @logger.info "[ === ] #{object}::#{method}"
      @logger.info uri.to_s
    end

    if @test_only
      @logger.info uri.request_uri
      return []
    end

    # https connection
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.is_a? URI::HTTPS
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      @logger.info response
      fail "OTRS Connection Error: #{response.code} #{response.message}"
    end

    result = ActiveSupport::JSON.decode(response.body.tr("\"", "\""))
    if result['Result'] == 'successful'
      result['Data']
    else
      @logger.info response.to_json
      fail "OTRS Error:#{result['Result']} #{result['Data']} #{result['Message']}"
    end
  end

end