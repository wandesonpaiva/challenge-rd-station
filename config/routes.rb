require 'sidekiq/web'

Rails.application.routes.draw do
  resource :cart, only: [:create, :show] do
    post :add_item, to: 'carts#add_item'
    delete "/:product_id", to: 'carts#remove_item'
  end

  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  if Rails.env.test?
    post '/set_session', to: 'test_helpers#set_session'
  end
end
