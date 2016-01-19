Rails.application.routes.draw do
  devise_for :players

  resources :games do
    resources :game_states, shallow: true, except: [:new, :edit, :index] do
      resources :scrap_holds, :trades, shallow: true, except: :index
      resources :blueprint_holds, shallow: true, except: :index do
        resources :module_holds, shallow: true, except: :index
      end
    end
  end

  root to: "games#index"
end
