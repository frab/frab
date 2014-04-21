Frab::Application.routes.draw do

  scope "(:locale)" do

    resource :session

    get "/conferences/new" => "conferences#new", as: "new_conference"
    post "/conferences" => "conferences#create", as: "create_conference"
    get "/conferences" => "conferences#index", as: "conference_index"
    delete "/conferences" => "conferences#destroy"

    resources :people do
      resource :user
      member do
        put :attend
      end
    end

    scope path: "/:conference_acronym" do

      namespace :public do
        get "/schedule" => "schedule#index", as: "schedule_index"
        get "/schedule/style" => "schedule#style", as: "schedule_style"
        get "/schedule/:day" => "schedule#day", as: "schedule"
        get "/events" => "schedule#events", as: "events"
        get "/events/:id" => "schedule#event", as: "event"
        get "/speakers" => "schedule#speakers", as: "speakers"
        get "/speakers/:id" => "schedule#speaker", as: "speaker"

        resources :events do
          resource :feedback, controller: :feedback
        end
      end # namespace :public

      namespace :cfp do

        resource :session

        resource :user do
          resource :password
          resource :confirmation
        end

        resource :person do
          resource :availability
        end

        get "/events/:id/confirm/:token" => "events#confirm", as: "event_confirm_by_token"

        resources :events do
          member do
            put :withdraw
            put :confirm
          end
        end

        get "/open_soon" => "welcome#open_soon", as: "open_soon"
        get "/not_existing" => "welcome#not_existing", as: "not_existing"

        root to: "people#show"

      end # namespace :cfp

      get "/recent_changes" => "recent_changes#index", as: "recent_changes"

      post "/schedule.pdf" => "schedule#custom_pdf", as: "schedule_custom_pdf", defaults: {format: :pdf}
      get "/schedule" => "schedule#index", as: "schedule"
      get "/schedule/update_track" => "schedule#update_track", as: "schedule_update_track"
      put "/schedule/update_event" => "schedule#update_event", as: "schedule_update_event"
      get "/schedule/new_pdf" => "schedule#new_pdf", as: "new_schedule_pdf"
      get "/schedule/html_exports" => "schedule#html_exports"
      post "/schedule/create_static_export" => "schedule#create_static_export"
      get "/schedule/download_static_export" => "schedule#download_static_export"

      get "/statistics/events_by_state" => "statistics#events_by_state", as: "events_by_state_statistics"
      get "/statistics/language_breakdown" => "statistics#language_breakdown", as: "language_breakdown_statistics"
      get "/statistics/gender_breakdown" => "statistics#gender_breakdown", as: "gender_breakdown_statistics"

      resource :conference, except: [:new, :create] do
        get :edit_tracks
        get :edit_days
        get :edit_schedule
        get :edit_rooms
        get :edit_ticket_server
      end

      resource :call_for_papers do
        get :edit_notifications
      end
      get "/call_for_papers/default_notifications" => "call_for_papers#default_notifications", as: "call_for_papers_default_notifications"

      resources :people do
        resource :user
        resource :availability
        collection do
          get :all
          get :feedbacks
          get :speakers
        end
      end

      resources :events do
        collection do
          get :my
          get :ratings
          get :feedbacks
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

      get "/reports" => "reports#index", as: "reports"
      get "/reports/on_people/:id" => "reports#show_people", as: "report_on_people"
      get "/reports/on_events/:id" => "reports#show_events", as: "report_on_events"
      get "/reports/on_statistics/:id" => "reports#show_statistics", as: "report_on_statistics"

      resources :tickets do
        member do
          post :create
        end
      end

    end # scope path: "/:conference_acronym"

    get "/:conference_acronym" => "home#index", as: "conference_home"

  end # scope "(:locale)" do

  root to: "home#index"

end
