Rails.application.routes.draw do

  root 'static_pages#home'
  devise_for :users

  resources :users, only: [:show, :edit, :update] do 
    resource :avatar, only: [:create, :destroy]
  end

  resources :events do 
    resources :images, only: [:create, :destroy]
    resources :comments, only: [:create], module: :events
  end
  
  resources :comments do 
    resources :comments, only: [:create], module: :comments
  end

  resources :participations, only: [:index, :new, :create, :destroy]

  namespace :admin do
    root to: "events#index"
    resources :users
    resources :events do 
      put "unvalidate", on: :member
    end
    resources :comments
    resources :participations, except: [:index]
    resources :event_submissions, except: [:new] do 
      put "validate", on: :member
    end
  end

  get 'about', to: 'static_pages#about'
  get 'contact', to: 'static_pages#contact'
  get 'submission_success', to: 'events#submission_success'
  get 'thanks', to: 'participations#thanks', as: 'thanks'
end