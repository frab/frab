Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'auth/registrations',
    sessions: 'auth/sessions'
  }

  scope '(:locale)' do

    get '/conferences/new' => 'conferences#new', as: 'new_conference'
    post '/conferences' => 'conferences#create', as: 'create_conference'
    get '/conferences' => 'conferences#index', as: 'conference_index'
    delete '/conferences' => 'conferences#destroy'

    get '/conferences/past' => 'home#past', as: 'past_conferences'

    get '/conference_users' => 'conference_users#index', as: 'conference_users'
    get '/admin_users' => 'conference_users#admins', as: 'admin_users'
    delete '/conference_users' => 'conference_users#destroy'

    get '/profile' => 'crew_profiles#edit', as: 'edit_crew_profile'
    patch '/profile' => 'crew_profiles#update', as: 'update_crew_profile'

    get '/user/:person_id/edit' => 'users#edit', as: 'edit_crew_user'
    patch '/user/:person_id' => 'users#update', as: 'crew_user'
    post '/user/:person_id' => 'users#create'

    scope path: '/:conference_acronym' do
      namespace :public do
        get '/schedule' => 'schedule#index', as: 'schedule_index'
        get '/schedule/style' => 'schedule#style', as: 'schedule_style'
        get '/schedule/:day' => 'schedule#day', as: 'schedule'
        get '/events' => 'schedule#events', as: 'events'
        get '/timeline' => 'schedule#timeline', as: 'timeline'
        get '/booklet' => 'schedule#booklet', as: 'booklet'
        get '/events/:id' => 'schedule#event', as: 'event'
        get '/speakers' => 'schedule#speakers', as: 'speakers'
        get '/speakers/:id' => 'schedule#speaker', as: 'speaker'
        get '/qrcode' => 'schedule#qrcode', as: 'qrcode'
        resources :events do
          resource :feedback, controller: :feedback
        end
      end # namespace :public

      namespace :cfp do
        resource :user, except: %i(new create)
        resource :person do
          resource :availability
        end
        get '/events/:id/confirm/:token' => 'events#confirm', as: 'event_confirm_by_token'
        resources :events do
          member do
            put :withdraw
            put :confirm
          end
        end
        root to: 'welcome#show'
      end # namespace :cfp

      get '/recent_changes' => 'recent_changes#index', as: 'recent_changes'
      post '/schedule.pdf' => 'schedule#custom_pdf', as: 'schedule_custom_pdf', defaults: { format: :pdf }
      get '/schedule' => 'schedule#index', as: 'schedule'
      get '/schedule/update_track' => 'schedule#update_track', as: 'schedule_update_track'
      put '/schedule/update_event' => 'schedule#update_event', as: 'schedule_update_event'
      get '/schedule/new_pdf' => 'schedule#new_pdf', as: 'new_schedule_pdf'
      get '/schedule/html_exports' => 'schedule#html_exports'
      post '/schedule/create_static_export' => 'schedule#create_static_export'
      get '/schedule/download_static_export' => 'schedule#download_static_export'

      get '/statistics/events_by_state' => 'statistics#events_by_state', as: 'events_by_state_statistics'
      get '/statistics/language_breakdown' => 'statistics#language_breakdown', as: 'language_breakdown_statistics'
      get '/statistics/gender_breakdown' => 'statistics#gender_breakdown', as: 'gender_breakdown_statistics'

      resource :conference, except: [:new, :create] do
        get :edit_tracks
        get :edit_days
        get :edit_schedule
        get :edit_rooms
        get :edit_ticket_server
        get :edit_notifications
        post :send_notification
      end
      get '/conferences/default_notifications' => 'conferences#default_notifications', as: 'conferences_default_notifications'

      resource :call_for_participation

      resources :people do
        resource :user
        resource :availability, except: %i(create show)
        resources :expenses
        resources :transport_needs
        collection do
          get :all
          get :feedbacks
          get :speakers
        end
        member do
          put :attend
        end
      end

      resources :events do
        collection do
          get :my
          get :ratings
          get :feedbacks
          get :start_review
          get :cards
          get :export_accepted
          get :export_confirmed
        end
        member do
          get :people
          get :edit_people
          get :ticket
          put :update_state
          post :custom_notification
        end
        resource :event_rating
        resources :event_feedbacks
      end

      get '/reports' => 'reports#index', as: 'reports'
      get '/reports/on_people/:id' => 'reports#show_people', as: 'report_on_people'
      get '/reports/on_events/:id' => 'reports#show_events', as: 'report_on_events'
      get '/reports/on_statistics/:id' => 'reports#show_statistics', as: 'report_on_statistics'
      get '/reports/on_transport_needs/:id' => 'reports#show_transport_needs', as: 'report_on_transport_needs'

      post '/tickets/:id/person' => 'tickets#create_person', as: 'create_person_ticket'
      post '/tickets/:id/event' => 'tickets#create_event', as: 'create_event_ticket'

      resources :mail_templates do
        member do
          put :send_mail
        end
      end
    end # scope path: "/:conference_acronym"
    get '/:conference_acronym' => 'conferences#show', as: 'conference_crew'
  end # scope "(:locale)" do

  root to: 'home#index'
end
