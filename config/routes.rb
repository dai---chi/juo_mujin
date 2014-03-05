Ws42::Application.routes.draw do
  get "static_pages/home"
  match '/help', to: 'static_pages#help', via: 'get'
  match '/menko', to: 'static_pages#menko', via: 'get'
  # get "public/index"
  # root to: "public#index"
  root  'static_pages#home'
end
