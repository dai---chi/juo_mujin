Ws42::Application.routes.draw do
  get "static_pages/home"
  get "static_pages/help"
  # get "public/index"
  # root to: "public#index"
  root  'static_pages#home'
end
