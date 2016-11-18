defmodule RallyApi.ProjectScopeTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.RallyQuery
  alias RallyApi.{Client, QueryResult}

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  # Parent Project
  @parent_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/76001020472"
  # Child Project
  @child_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/76175116672"

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end
  
  # Ensight Enterprises (Workspace)
  # |- REST Toolkit for Elixir (Project)
  #    |- User Story 1
  #    |- Sub Project 1 (Project)
  #       |- User Story 2

  @tag :skip # cannot create sub projects in free community version
  test "find with project scope down false" do
    # use_cassette "project#find_without_project_scope_down", match_requests_on: [:query] do
    #   {:ok, %QueryResult{} = result} = find(
    #     @client, :story, "(Name contains \"Child Story\")", "FormattedID,Name", 
    #     project: @parent_ref, projectScopeDown: false
    #   )
    #   assert result.total_result_count == 0
    # end
  end

  @tag :skip # cannot create sub projects in free community version
  test "find with project scope down true" do
    # use_cassette "project#find_with_project_scope_down", match_requests_on: [:query] do
    #   {:ok, %QueryResult{} = result} = find(
    #     @client, :story, "(Name contains \"Child Story\")", "",
    #     project: @parent_ref, projectScopeDown: true
    #   )
    #   assert result.total_result_count > 0
    # end
  end

  @tag :skip # cannot create sub projects in free community version
  test "find with project scope up false" do
    # use_cassette "project#find_without_project_scope_up", match_requests_on: [:query] do
    #   {:ok, %QueryResult{} = result} = find(
    #     @client, :story, "(FormattedID = US914)", "FormattedID,Name",
    #     project: @child_ref, projectScopeUp: false
    #   )
    #   assert result.total_result_count == 0
    # end
  end 
  
  @tag :skip # cannot create sub projects in free community version
  test "find with project scope up true" do
    # use_cassette "project#find_with_project_scope_up", match_requests_on: [:query] do
    #   {:ok, %QueryResult{} = result} = find(
    #     @client, :story, "(FormattedID = US914)", "FormattedID,Name",
    #     project: @child_ref, projectScopeUp: true
    #   )
    #   assert result.total_result_count == 1
    # end
  end
end
