SampleApp::Application.routes.draw do
  #root to: 'static_pages#home'
  root to: 'voxels#index'

  get "static_editors/index"
  get "static_editors/home"
  get "static_editors/help"
  resources :voxels

  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :sessions,      only: [:new, :create, :destroy]
  resources :microposts,    only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]

  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'

  #by me
  match '/random', to: 'voxels#random', via: 'get'
  match '/voxels/view/:id', to: 'voxels#view', via: 'get'

  match '/test', :to => redirect('/test.html')
end
