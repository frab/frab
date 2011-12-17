Frab::Application.routes.draw do

  scope "(:locale)" do

    resource :session

    match "/conferences/new" => "conferences#new", :as => "new_conference"
    match "/conferences" => "conferences#create", :as => "create_conference"

    scope :path => "/:conference_acronym" do
     
      namespace :public do
        match "/schedule" => "schedule#index", :as => "schedule_index"
        match "/schedule/style" => "schedule#style", :as => "schedule_style"
        match "/schedule/:date" => "schedule#day", :as => "schedule"
        match "/events" => "schedule#events", :as => "events"
        match "/events/:id" => "schedule#event", :as => "event"
        match "/speakers" => "schedule#speakers", :as => "speakers"
        match "/speakers/:id" => "schedule#speaker", :as => "speaker"
        
        resources :events do
          resource :feedback, :controller => :feedback
        end
      end

      namespace :cfp do

        resource :session
        
        resource :user do 
          resource :password
          resource :confirmation
        end

        resource :person do
          resource :availability
        end

        match "/events/:id/confirm/:token" => "events#confirm", :as => "event_confirm_by_token"

        resources :events do
          member do
            put :withdraw
            put :confirm
          end
        end

        match "/open_soon" => "welcome#open_soon", :as => "open_soon"

        root :to => "people#show"

      end
      
      match "/recent_changes" => "recent_changes#index", :as => "recent_changes"

      match "/schedule.pdf" => "schedule#custom_pdf", :as => "schedule_custom_pdf", :defaults => {:format => :pdf}
      match "/schedule" => "schedule#index", :as => "schedule"
      match "/schedule/update_track" => "schedule#update_track", :as => "schedule_update_track"
      match "/schedule/update_event" => "schedule#update_event", :as => "schedule_update_event"
      match "/schedule/new_pdf" => "schedule#new_pdf", :as => "new_schedule_pdf"

      match "/statistics/events_by_state" => "statistics#events_by_state", :as => "events_by_state_statistics"
      match "/statistics/language_breakdown" => "statistics#language_breakdown", :as => "language_breakdown_statistics"

      resource :conference, :except => [:new, :create] do
        get :edit_tracks
        get :edit_rooms
        get :edit_ticket_server
      end

      resource :call_for_papers

      resources :people do
        resource :user
        collection do
          get :all
          get :speakers
        end
      end

      resources :events do
        collection do
          get :my
          get :ratings
          get :start_review
          get :cards
        end
        member do
          get :people
          get :edit_people
          get :ticket
          put :update_state
        end
        resource :event_rating
        resources :event_feedbacks
      end

      resources :tickets do
        member do
          post :create
        end
      end

    end

    match "/:conference_acronym" => "home#index", :as => "conference_home"
    root :to => "home#index"
  end

  root :to => "home#index"

end
