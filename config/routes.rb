Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post 'user/:id/schedule', to: 'scheduler#register_schedule'
  get 'user/:id/schedule', to: "scheduler#get_schedule"
  get 'user/:id/schedule/followers', to: "scheduler#get_followers_schedule"
  post 'follow_user', to: 'follower#follow_user'
  delete 'follow_user', to: 'follower#delete_follow'
end
