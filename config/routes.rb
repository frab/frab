Frab::Application.routes.draw do

  scope "(:locale)" do
  
    devise_for :users

    resources :conferences

    scope :path => "/:conference_acronym" do
      
      match "/recent_changes" => "recent_changes#index", :as => "recent_changes"

      resource :conference

      resource :call_for_papers

      resources :people do
        resource :user
      end

      resources :events do
        member do
          get :edit_persons
        end
      end

      namespace :cfp do

        devise_for :users

        resource :person do
          resource :availability
        end

        resources :events do
          member do
            put :withdraw
          end
        end

        match "/open_soon" => "welcome#open_soon", :as => "open_soon"

        root :to => "people#show"

      end
    end
    
    root :to => "home#index"
  end

  root :to => "home#index"

end
