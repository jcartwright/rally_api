defmodule RallyApi.ProjectScopeTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.RallyQuery
  alias RallyApi.{Client, QueryResult}

  @client Client.new(%{zsessionid: "_lopoalp1TxyqCH3p7s1FWco2ROI90uxpii7ubJYH8"})
  # Testing Sandbox
  @parent_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530"
  # Test Project 1
  @child_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/55700974877"
  
  # Training Sandbox
  # |- Test Project 1
  #    |- Child Story in Test Project 1
  # |- Test Project 2
  #    |- Child Story in Test Project 2

  test "find with project scope down false" do
    use_cassette "project#find_without_project_scope_down", match_requests_on: [:query] do
      {:ok, %QueryResult{} = result} = find(
        @client, :story, "(Name contains \"Child Story\")", "FormattedID,Name", 
        project: @parent_ref, projectScopeDown: false
      )
      assert result.total_result_count == 0
    end
  end

  test "find with project scope down true" do
    use_cassette "project#find_with_project_scope_down", match_requests_on: [:query] do
      {:ok, %QueryResult{} = result} = find(
        @client, :story, "(Name contains \"Child Story\")", "",
        project: @parent_ref, projectScopeDown: true
      )
      assert result.total_result_count > 0
    end
  end

  test "find with project scope up false" do
    use_cassette "project#find_without_project_scope_up", match_requests_on: [:query] do
      {:ok, %QueryResult{} = result} = find(
        @client, :story, "(FormattedID = US914)", "FormattedID,Name",
        project: @child_ref, projectScopeUp: false
      )
      assert result.total_result_count == 0
    end
  end 
  
  test "find with project scope up true" do
    use_cassette "project#find_with_project_scope_up", match_requests_on: [:query] do
      {:ok, %QueryResult{} = result} = find(
        @client, :story, "(FormattedID = US914)", "FormattedID,Name",
        project: @child_ref, projectScopeUp: true
      )
      assert result.total_result_count == 1
    end
  end
end
