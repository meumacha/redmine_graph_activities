Rails.application.routes.draw do 
  match 'projects/:id/graph_activities/:action', :to => 'graph_activities#view'
end
