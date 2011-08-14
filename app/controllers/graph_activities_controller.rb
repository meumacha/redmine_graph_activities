require 'SVG/Graph/Bar'

class GraphActivitiesController < ApplicationController
  unloadable

  layout 'base'
  before_filter :init

  def init
    @project = Project.find(params[:id])
    @assignables = @project.assignable_users
    @author = (params[:user_id].blank? ? nil : User.active.find(params[:user_id]))

    @activity = Redmine::Activity::Fetcher.new(User.current, :project => @project,
                                                             :with_subprojects => 1,
                                                             :author => @author )
    @activity.scope_select {|t| !params["show_#{t}"].nil?}
    @activity.scope = (@author.nil? ? :default : :all) if @activity.scope.empty?

    @events = @activity.events(Date.today - 28, Date.today + 1)

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def view
  end

  def graph
    data = make_graph
    headers["Content-Type"] = "image/svg+xml"
    send_data(data, :type => "image/svg+xml", :disposition => "inline")
  end

  def graph_issue_per_day
    data = make_graph_issue_per_day
    headers["Content-Type"] = "image/svg+xml"
    send_data(data, :type => "image/svg+xml", :disposition => "inline")
  end

  def graph_repos_per_day
    data = make_graph_repos_per_day
    headers["Content-Type"] = "image/svg+xml"
    send_data(data, :type => "image/svg+xml", :disposition => "inline")
  end

  private
  def make_graph
    act_issues = Array.new(24, 0)
    act_repos = Array.new(24, 0)
    field = Array.new(24){|i| i}

    @events.each do |e|
      if e.event_type[0..4] == 'issue'
        act_issues[ e.event_datetime.strftime("%H").to_i ] += 1
      elsif e.event_type == 'changeset'
        act_repos[ e.event_datetime.strftime("%H").to_i ] += 1
      end
    end
    graph = SVG::Graph::Bar.new ({
      :height => 400,
      :width => 960,
      :fields => field,
      :stack => :side,
      :scale_integers => true,
      :step_x_labels => 1,
      :show_data_values => true,
      :graph_title => l(:all_activities),
      :show_graph_title => true
    })

    graph.add_data({
      :data => act_issues,
      :title => l(:act_issue)
    })
    graph.add_data({
      :data => act_repos,
      :title => l(:act_repos)
    })

    graph.burn
  end

  def make_graph_issue_per_day
    act_issues = Array.new
    7.times do |i|
      act_issues.push( Array.new(24, 0) )
    end

    field = Array.new(24){|i| i}

    @events.each do |e|
      if e.event_type[0..4] == 'issue'
        d = e.event_datetime.strftime("%w").to_i
        t = e.event_datetime.strftime("%H").to_i
        act_issues[d][t] += 1
      end
    end
    graph = SVG::Graph::Bar.new ({
      :height => 400,
      :width => 960,
      :fields => field,
      :stack => :side,
      :scale_integers => true,
      :step_x_labels => 1,
      :show_data_values => false,
      :graph_title => l(:activities_issue_per_day),
      :show_graph_title => true
    })

    day_labels = [l(:sun), l(:mon), l(:tue), l(:wed), l(:thu), l(:fri), l(:sat) ]
    7.times do |i|
      graph.add_data({
        :data => act_issues[i],
        :title => day_labels[i]
      })
    end
    graph.burn
  end

  def make_graph_repos_per_day
    act_repos = Array.new
    7.times do |i|
      act_repos.push( Array.new(24, 0) )
    end

    field = Array.new(24){|i| i}

    @events.each do |e|
      if e.event_type == 'changeset'
        d = e.event_datetime.strftime("%w").to_i
        t = e.event_datetime.strftime("%H").to_i
        act_repos[d][t] += 1
      end
    end
    graph = SVG::Graph::Bar.new ({
      :height => 400,
      :width => 960,
      :fields => field,
      :stack => :side,
      :scale_integers => true,
      :step_x_labels => 1,
      :show_data_values => false,
      :graph_title => l(:activities_repos_per_day),
      :show_graph_title => true
    })

    day_labels = [l(:sun), l(:mon), l(:tue), l(:wed), l(:thu), l(:fri), l(:sat) ]
    7.times do |i|
      graph.add_data({
        :data => act_repos[i],
        :title => day_labels[i]
      })
    end
    graph.burn
  end
end
