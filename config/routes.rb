Frab::Application.routes.draw do

  scope "(:locale)" do
  
    devise_for :users, :controllers => {:sessions => "sessions"}, :skip => :registrations

    resources :conferences

    scope :path => "/:conference_acronym" do
      
      namespace :cfp do

        devise_for :users

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

      match "/schedule" => "schedule#index", :as => "schedule"
      match "/schedule/update_track" => "schedule#update_track", :as => "schedule_update_track"

      resource :conference

      resource :call_for_papers

      resources :people do
        resource :user
      end

      resources :events do
        collection do
          get :my
          get :ratings
          get :start_review
          get :cards
        end
        member do
          get :edit_persons
          put :update_state
        end
        resource :event_rating
      end

    end
    
    root :to => "home#index"
  end

  root :to => "home#index"

end
