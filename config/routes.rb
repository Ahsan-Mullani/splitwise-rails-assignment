Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users

  # Root dashboard after login
  root to: "static#dashboard"

  # View details and balances for a specific person/friend
  get "people/:id", to: "static#person", as: :person

  # Create expenses (handled via form submission)
  resources :expenses, only: [:create]

  # Create settlements between users
  resources :settlements, only: [:create]
end
