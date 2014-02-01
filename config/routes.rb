LogJam::Application.routes.draw do
  get "/stats/systems", to: 'log_stats#systems', as: :systems
  
  delete '/ops/clear-index', to: 'log_stats#clear_index', as: :clear_index

  get "/facets", to: 'log_view#facets', as: :facets
  
  get '/poll', to: 'log_view#poll', as: :poll

  root 'log_view#index'
end
