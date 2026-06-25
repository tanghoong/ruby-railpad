Rails.application.routes.draw do
  resources :articles

  resources :gists do
    member do
      post :run
    end
  end

  # Health check endpoint (used by load balancers / uptime monitors)
  get "up" => "rails/health#show", as: :rails_health_check

  # Redirect legacy favicon.ico requests to the SVG icon
  get "/favicon.ico", to: redirect("/icon.svg", status: 301)

  root "articles#index"
end
