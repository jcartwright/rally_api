defmodule RallyApi.ProjectsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import RallyApi.Projects

  doctest RallyApi.Projects

  @client RallyApi.Client.new(%{zsessionid: "_lopoalp1TxyqCH3p7s1FWco2ROI90uxpii7ubJYH8"})
  @_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530"

  setup_all do
    HTTPoison.start
  end

  test "list/1" do
    use_cassette "projects#list" do
      {:ok, projects} = list(@client)
      refute Enum.empty?(projects.results)
      assert Enum.reject(projects.results, &(&1["_type"] == "Project")) == []
    end
  end

  test "find/2 query, client" do
    use_cassette "projects#find", match_requests_on: [:query] do
      {:ok, %RallyApi.QueryResult{results: projects}} = find(@client, "(Name = \"Training Sandbox\")")
      [%{"_refObjectName" => name}] = projects
      assert name == "Training Sandbox"

      {:ok, %RallyApi.QueryResult{results: projects}} = find(@client, "(Owner.LastName = Cartwright)")
      assert Enum.map(projects, &(&1["_refObjectName"])) == ["NewCo Products", "Data Architecture"]
    end
  end

  test "read/2 _ref, client" do
    use_cassette "projects#read" do
      {:ok, %{"Project" => %{"_ref" => ref}}} = read(@client, @_ref)
      assert ref == @_ref
    end
  end
end
