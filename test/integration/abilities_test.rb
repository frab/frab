require 'test_helper'

class AbilitiesTest < ActionDispatch::IntegrationTest
  # Roles = (g)uest (s)ubmitter (a)dmin (r)eviewer (c)oordinator
  ROLE_ADMIN = 'a'
  ROLE_COORDINATOR = 'c'
  ROLE_SUBMITTER = 's'
  ROLE_REVIEWER = 'r'
  ROLE_GUEST = 'g'
  # Array Indexes
  METHOD_INDEX = 0
  PATH_INDEX = 1
  #PARAMS_INDEX = 2
  DESCR_INDEX = 2
  ROLES_INDEX = 3

  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    @c = @conference
    @person = FactoryGirl.create(:person)

    # 
    @speaker = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, :event => @event, :person => @speaker, :event_role => "speaker")

    #
    @feedback = FactoryGirl.create(:event_feedback, :event => @event, :rating => 4.0)

    #
    @cfp = FactoryGirl.create(:call_for_papers, :conference => @conference)

    #
    @ticket = FactoryGirl.create(:ticket, :event => @event)

    # users
    @admin = create(:user, :person => create(:person), :role => "admin")

    #
    date = @conference.days.first.start_date.strftime('%Y-%m-%d')

=begin non existent controller methods?
get   , /session/edit                                                          ,  sessions#edit                         ,   a
get   , /session                                                               ,  sessions#show                         ,   a
put   , /session                                                               ,  sessions#update                       ,   a
get   , /#{@c.acronym}/conference/edit_tracks                                  ,  conferences#edit_tracks               ,   a
get   , /#{@c.acronym}/conference/edit_rooms                                   ,  conferences#edit_rooms                ,   a
get   , /#{@c.acronym}/conference/edit_ticket_server                           ,  conferences#edit_ticket_server        ,   a
get   , /#{@c.acronym}/public/events/#{@event.id}/feedback/edit                ,  public/feedback#edit                  ,   a
get   , /#{@c.acronym}/public/events/#{@event.id}/feedback                     ,  public/feedback#show                  ,   a
put   , /#{@c.acronym}/public/events/#{@event.id}/feedback                     ,  public/feedback#update                ,   a
delete, /#{@c.acronym}/public/events/#{@event.id}/feedback                     ,  public/feedback#destroy               ,   a
get   , /#{@c.acronym}/public/events                                           ,  public/events#index                   ,   a
post  , /#{@c.acronym}/public/events                                           ,  public/events#create                  ,   a
get   , /#{@c.acronym}/public/events/new                                       ,  public/events#new                     ,   a
get   , /#{@c.acronym}/public/events/#{@event.id}/edit                         ,  public/events#edit                    ,   a
get   , /#{@c.acronym}/public/events/#{@event.id}                              ,  public/events#show                    ,   a
put   , /#{@c.acronym}/public/events/#{@event.id}                              ,  public/events#update                  ,   a
delete, /#{@c.acronym}/public/events/#{@event.id}                              ,  public/events#destroy                 ,   a
get   , /#{@c.acronym}/cfp/session/edit                                        ,  cfp/sessions#edit                     ,   a s g
get   , /#{@c.acronym}/cfp/session                                             ,  cfp/sessions#show                     ,   a s g
put   , /#{@c.acronym}/cfp/session                                             ,  cfp/sessions#update                   ,   a s g
delete, /#{@c.acronym}/cfp/user/password                                       ,  cfp/passwords#destroy                 ,   a
get   , /#{@c.acronym}/cfp/user/password                                       ,  cfp/passwords#show                    ,   a
get   , /#{@c.acronym}/cfp/user/confirmation/edit                              ,  cfp/confirmations#edit                ,   a
put   , /#{@c.acronym}/cfp/user/confirmation                                   ,  cfp/confirmations#update              ,   a
delete, /#{@c.acronym}/cfp/user/confirmation                                   ,  cfp/confirmations#destroy             ,   a
get   , /#{@c.acronym}/cfp/user                                                ,  cfp/users#show                        ,   a
delete, /#{@c.acronym}/cfp/user                                                ,  cfp/users#destroy                     ,   a
post  , /#{@c.acronym}/cfp/person/availability                                 ,  cfp/availabilities#create             ,   a
get   , /#{@c.acronym}/cfp/person/availability                                 ,  cfp/availabilities#show               ,   a
delete, /#{@c.acronym}/cfp/person/availability                                 ,  cfp/availabilities#destroy            ,   a
get   , /#{@c.acronym}/cfp/person/availability/edit                            ,  cfp/availabilities#edit               ,   s
put   , /#{@c.acronym}/cfp/person/availability                                 ,  cfp/availabilities#update             ,   s
delete, /#{@c.acronym}/cfp/person                                              ,  cfp/people#destroy                    ,   a
delete, /#{@c.acronym}/call_for_papers                                         ,  call_for_papers#destroy               ,   a
post  , /#{@c.acronym}/events/#{@event.id}/event_feedbacks                     ,  event_feedbacks#create                ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_feedbacks/new                 ,  event_feedbacks#new                   ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_feedbacks/#{@feedback.id}/edit,  event_feedbacks#edit                  ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_feedbacks/#{@feedback.id}     ,  event_feedbacks#show                  ,   a
put   , /#{@c.acronym}/events/#{@event.id}/event_feedbacks/#{@feedback.id}     ,  event_feedbacks#update                ,   a
delete, /#{@c.acronym}/events/#{@event.id}/event_feedbacks/#{@feedback.id}     ,  event_feedbacks#destroy               ,   a
post  , /#{@c.acronym}/tickets                                                 ,  tickets#create                        ,   a
get   , /#{@c.acronym}/tickets                                                 ,  tickets#index                         ,   a
get   , /#{@c.acronym}/tickets/new                                             ,  tickets#new                           ,   a
get   , /#{@c.acronym}/tickets/#{@ticket.id}/edit                              ,  tickets#edit                          ,   a
get   , /#{@c.acronym}/tickets/#{@ticket.id}                                   ,  tickets#show                          ,   a
put   , /#{@c.acronym}/tickets/#{@ticket.id}                                   ,  tickets#update                        ,   a
delete, /#{@c.acronym}/tickets/#{@ticket.id}                                   ,  tickets#destroy                       ,   a
get   , /#{@c.acronym}/events/#{@event.id}/ticket                              ,  events#ticket                         ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_rating/new                    ,  event_ratings#new                     ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_rating/edit                   ,  event_ratings#edit                    ,   a

= do not test session, because test cases are not robust
post  , /session                                                               ,  sessions#create                       ,   a s g
get   , /session/new                                                           ,  sessions#new                          ,   a s g
delete, /session                                                               ,  sessions#destroy                      ,   a s
post  , /#{@c.acronym}/cfp/session                                             ,  cfp/sessions#create                   ,   a s g
get   , /#{@c.acronym}/cfp/session/new                                         ,  cfp/sessions#new                      ,   a s g
delete, /#{@c.acronym}/cfp/session                                             ,  cfp/sessions#destroy                  ,   a s g
delete, /#{@c.acronym}/conference                                              ,  conferences#destroy                   ,   a

= missing parameters
get   , /#{@c.acronym}/conference                                              ,  conferences#show                      ,   a
put   , /#{@c.acronym}/conference                                              ,  conferences#update                    ,   a
      , /#{@c.acronym}/public/events/#{@event.id}                              ,  public/schedule#event                 ,   a s g
      , /#{@c.acronym}/public/speakers/#{@speaker.id}                          ,  public/schedule#speaker               ,   a s g
get   , /#{@c.acronym}/cfp/person/new                                          ,  cfp/people#new                        ,   s
get   , /#{@c.acronym}/cfp/person/edit                                         ,  cfp/people#edit                       ,   s
post  , /#{@c.acronym}/cfp/user/password                                       ,  cfp/passwords#create                  ,   a s g
get   , /#{@c.acronym}/cfp/user/confirmation                                   ,  cfp/confirmations#show                ,   a s g
put   , /#{@c.acronym}/cfp/user/password                                       ,  cfp/passwords#update                  ,   a s g
post  , /#{@c.acronym}/cfp/user/confirmation                                   ,  cfp/confirmations#create              ,   a s g
      , /#{@c.acronym}/schedule.pdf                                            ,  schedule#custom_pdf {:format=>:pdf}   ,   a
      , /#{@c.acronym}/schedule/update_event                                   ,  schedule#update_event                 ,   a
post  , /#{@c.acronym}/cfp/user                                                ,  cfp/users#create                      ,   a s g
get   , /#{@c.acronym}/cfp/user/edit                                           ,  cfp/users#edit                        ,   a s
post  , /#{@c.acronym}/cfp/events                                              ,  cfp/events#create                     ,   s
get   , /#{@c.acronym}/cfp/events/new                                          ,  cfp/events#new                        ,   s
      , /#{@c.acronym}/cfp                                                     ,  cfp/people#show                       ,   s
put   , /#{@c.acronym}/events/#{@event.id}/event_rating                        ,  event_ratings#update                  ,   a
put   , /#{@c.acronym}/events/#{@event.id}/update_state                        ,  events#update_state                   ,   a
get   , /#{@c.acronym}/events/#{@event.id}                                     ,  events#show                           ,   a
delete, /#{@c.acronym}/events/#{@event.id}                                     ,  events#destroy                        ,   a
get   , /#{@c.acronym}/people/#{@person.id}/user/edit                          ,  users#edit                            ,   a
post  , /#{@c.acronym}/people/#{@person.id}/user                               ,  users#create                          ,   a
put   , /#{@c.acronym}/people/#{@person.id}/user                               ,  users#update                          ,   a
get   , /#{@c.acronym}/cfp/person                                              ,  cfp/people#show                       ,   s
post  , /#{@c.acronym}/tickets/#{@ticket.id}                                   ,  tickets#create                        ,   a

= redirects
      , /conferences/new                                                       ,  conferences#new                       ,   a
get   , /#{@c.acronym}/cfp/person/availability/new                             ,  cfp/availabilities#new                ,   s
      , /#{@c.acronym}/cfp/events/#{@event.id}/confirm/1234                    ,  cfp/events#confirm                    ,   s g
put   , /#{@c.acronym}/cfp/user                                                ,  cfp/users#update                      ,   a s
      , /#{@c.acronym}/cfp/open_soon                                           ,  cfp/welcome#open_soon                 ,   a s g
      , /#{@c.acronym}/statistics/events_by_state                              ,  statistics#events_by_state            ,   a
      , /#{@c.acronym}/statistics/language_breakdown                           ,  statistics#language_breakdown         ,   a
put   , /#{@c.acronym}/call_for_papers                                         ,  call_for_papers#update                ,   a
get   , /#{@c.acronym}/people/#{@person.id}/user                               ,  users#show                            ,   a
delete, /#{@c.acronym}/people/#{@person.id}/user                               ,  users#destroy                         ,   a
put   , /#{@c.acronym}/people/#{@person.id}/availability                       ,  availabilities#update                 ,   a
put   , /#{@c.acronym}/people/#{@person.id}                                    ,  people#update                         ,   a
get   , /#{@c.acronym}/events/start_review                                     ,  events#start_review                   ,   a
get   , /#{@c.acronym}/events/cards                                            ,  events#cards                          ,   a
post  , /#{@c.acronym}/events/#{@event.id}/event_rating                        ,  event_ratings#create                  ,   a
put   , /#{@c.acronym}/events/#{@event.id}                                     ,  events#update                         ,   a
get   , /#{@c.acronym}/people/#{@person.id}/availability                       ,  availabilities#show                   ,   a
post  , /#{@c.acronym}/people/#{@person.id}/availability                       ,  availabilities#create                 ,   a
delete, /#{@c.acronym}/people/#{@person.id}/availability                       ,  availabilities#destroy                ,   a

=end
    routes_csv = <<EOF
      , /conferences                                                           ,  conferences#create                    ,   a
get   , /#{@c.acronym}/conference/edit                                         ,  conferences#edit                      ,   a
      , /#{@c.acronym}/public/schedule                                         ,  public/schedule#index                 ,   a s g
      , /#{@c.acronym}/public/schedule/#{date}                                 ,  public/schedule#day                   ,   a s g
      , /#{@c.acronym}/public/schedule/style.css                               ,  public/schedule#style                 ,   a s g
      , /#{@c.acronym}/public/events                                           ,  public/schedule#events                ,   a s g
      , /#{@c.acronym}/public/speakers                                         ,  public/schedule#speakers              ,   a s g
post  , /#{@c.acronym}/public/events/#{@event.id}/feedback                     ,  public/feedback#create                ,   a s g
get   , /#{@c.acronym}/public/events/#{@event.id}/feedback/new                 ,  public/feedback#new                   ,   a s g
get   , /#{@c.acronym}/cfp/user/password/new                                   ,  cfp/passwords#new                     ,   a s g
get   , /#{@c.acronym}/cfp/user/password/edit                                  ,  cfp/passwords#edit                    ,   a s g
get   , /#{@c.acronym}/cfp/user/confirmation/new                               ,  cfp/confirmations#new                 ,   a s g
get   , /#{@c.acronym}/cfp/user/new                                            ,  cfp/users#new                         ,   a s g
post  , /#{@c.acronym}/cfp/person                                              ,  cfp/people#create                     ,   s
put   , /#{@c.acronym}/cfp/person                                              ,  cfp/people#update                     ,   s
put   , /#{@c.acronym}/cfp/events/#{@event.id}/withdraw                        ,  cfp/events#withdraw                   ,   s
put   , /#{@c.acronym}/cfp/events/#{@event.id}/confirm                         ,  cfp/events#confirm                    ,   s
get   , /#{@c.acronym}/cfp/events                                              ,  cfp/events#index                      ,   s
get   , /#{@c.acronym}/cfp/events/#{@event.id}/edit                            ,  cfp/events#edit                       ,   s
get   , /#{@c.acronym}/cfp/events/#{@event.id}                                 ,  cfp/events#show                       ,   s
put   , /#{@c.acronym}/cfp/events/#{@event.id}                                 ,  cfp/events#update                     ,   s
delete, /#{@c.acronym}/cfp/events/#{@event.id}                                 ,  cfp/events#destroy                    ,   s
      , /#{@c.acronym}/recent_changes                                          ,  recent_changes#index                  ,   a
      , /#{@c.acronym}/schedule                                                ,  schedule#index                        ,   a
      , /#{@c.acronym}/schedule/update_track                                   ,  schedule#update_track                 ,   a
      , /#{@c.acronym}/schedule/new_pdf                                        ,  schedule#new_pdf                      ,   a
post  , /#{@c.acronym}/call_for_papers                                         ,  call_for_papers#create                ,   a
get   , /#{@c.acronym}/call_for_papers/new                                     ,  call_for_papers#new                   ,   a
get   , /#{@c.acronym}/call_for_papers/edit                                    ,  call_for_papers#edit                  ,   a
get   , /#{@c.acronym}/call_for_papers                                         ,  call_for_papers#show                  ,   a
get   , /#{@c.acronym}/people/#{@person.id}/user/new                           ,  users#new                             ,   a
get   , /#{@c.acronym}/people/#{@person.id}/availability/new                   ,  availabilities#new                    ,   a
get   , /#{@c.acronym}/people/#{@person.id}/availability/edit                  ,  availabilities#edit                   ,   a
get   , /#{@c.acronym}/people/all                                              ,  people#all                            ,   a
get   , /#{@c.acronym}/people/speakers                                         ,  people#speakers                       ,   a
get   , /#{@c.acronym}/people                                                  ,  people#index                          ,   a
post  , /#{@c.acronym}/people                                                  ,  people#create                         ,   a
get   , /#{@c.acronym}/people/new                                              ,  people#new                            ,   a
get   , /#{@c.acronym}/people/#{@person.id}/edit                               ,  people#edit                           ,   a
get   , /#{@c.acronym}/people/#{@person.id}                                    ,  people#show                           ,   a
delete, /#{@c.acronym}/people/#{@person.id}                                    ,  people#destroy                        ,   a
get   , /#{@c.acronym}/events/my                                               ,  events#my                             ,   a
get   , /#{@c.acronym}/events/ratings                                          ,  events#ratings                        ,   a
get   , /#{@c.acronym}/events/feedbacks                                        ,  events#feedbacks                      ,   a
get   , /#{@c.acronym}/events/#{@event.id}/people                              ,  events#people                         ,   a
get   , /#{@c.acronym}/events/#{@event.id}/edit_people                         ,  events#edit_people                    ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_rating                        ,  event_ratings#show                    ,   a
delete, /#{@c.acronym}/events/#{@event.id}/event_rating                        ,  event_ratings#destroy                 ,   a
get   , /#{@c.acronym}/events/#{@event.id}/event_feedbacks                     ,  event_feedbacks#index                 ,   a
get   , /#{@c.acronym}/events                                                  ,  events#index                          ,   a
post  , /#{@c.acronym}/events                                                  ,  events#create                         ,   a
get   , /#{@c.acronym}/events/new                                              ,  events#new                            ,   a
get   , /#{@c.acronym}/events/#{@event.id}/edit                                ,  events#edit                           ,   a
      , /#{@c.acronym}/reports                                                 ,  reports#index                         ,   a
      , /#{@c.acronym}/reports/on_people/#{@speaker.id}                        ,  reports#show_people                   ,   a
      , /#{@c.acronym}/reports/on_events/#{@event.id}                          ,  reports#show_events                   ,   a
      , /#{@c.acronym}/reports/on_statistics/events_by_state                   ,  reports#show_statistics               ,   a
      , /#{@c.acronym}                                                         ,  home#index                            ,   a
EOF

    @routes = [] 
    routes_csv.each_line { |l| @routes << l.split(/,/).map{ |e| e.strip } }
  end

  def request(route, role)
    method = route[METHOD_INDEX]
    path = route[PATH_INDEX]
    name = route[DESCR_INDEX]
    #params = route[PARAMS_INDEX]

    puts "== #{name}    #{method} #{path}"
   
    begin
      case method
      when /post/
        post path
      when /put/
        put path
      else
        get path
      end
    rescue 
      puts "     failed: #{$!}"
    end

    roles = route[ROLES_INDEX]
    if roles.include?(role)
      assert_response :success
    else
      assert_response :redirect
    end
  end

  test "anonymous guest user" do
    @routes.each { |route|
      request(route, ROLE_GUEST)
    }
  end

  test "admin user" do
    post "/session", :user => {:email => @admin.email, :password => "frab23"}
    @routes.each { |route|
      request(route, ROLE_ADMIN)
    }
  end

end
