Rails.application.routes.draw do
  resources :books
  resources :authors, except: [:edit, :update, :show, :new, :create] do
    get 'edit_authors', to: 'authors#edit_authors'
    patch 'update_authors', to: 'authors#update_authors'
    get 'show_authors', to: 'authors#show_authors'
    get 'new_authors', to: 'authors#new_authors'
    post 'create_authors', to: 'authors#create_authors'
  end

  devise_for :authors
  devise_scope :author do
    get '/authors/sign_out' => 'devise/sessions#destroy'
  end
  root 'main#home'
end
