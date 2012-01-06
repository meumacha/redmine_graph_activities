require 'redmine'

Redmine::Plugin.register :redmine_graph_activities do
  name 'Redmine Graph Activities plugin'
  author '@me_umacha'
  description "The plugin to generate a graph for visualizing members' activities."
  version '0.0.2'

  # This plugin works as a project module and can be enabled/disabled at project level
  project_module :graph_activities do
    # All actions are public permission
    permission :graph_activities_view, {:graph_activities => [:view]}, :public => true
    permission :graph_activities_graph, {:graph_activities => [:graph]}, :public => true
    permission :graph_activities_graph_issue_per_day, {:graph_activities => [:graph_issue_per_day]}, :public => true
    permission :graph_activities_graph_repos_per_day, {:graph_activities => [:graph_repos_per_day]}, :public => true
  end

  # Add an item in project menu
  menu :project_menu,
       :graph_activities,
       {:controller=>'graph_activities', :action=>'view', :user_id=>'', :from=>'', :to=>''},
       :caption => :graph_activities_name

  # Settings
  settings :default => {'include_subproject' => '1'},
           :partial => 'settings/redmine_graph_activities_settings'
end
