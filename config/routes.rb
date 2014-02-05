# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'projects/:id/graph_activities' => 'graph_activities#view'
get 'projects/:id/graph_activities/graph' => 'graph_activities#graph'
get 'projects/:id/graph_activities/graph_issue_per_day' => 'graph_activities#graph_issue_per_day'
get 'projects/:id/graph_activities/graph_repos_per_day' => 'graph_activities#graph_repos_per_day'
