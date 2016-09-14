defmodule RallyApi.ProjectsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.Projects
  alias RallyApi.{Client, QueryResult}

  doctest RallyApi.Projects

  @client Client.new(%{zsessionid: "_lopoalp1TxyqCH3p7s1FWco2ROI90uxpii7ubJYH8"})
  @_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530"

  test "list/1" do
    use_cassette "projects#list" do
      {:ok, projects} = list(@client)
      refute Enum.empty?(projects.results)
      assert Enum.reject(projects.results, &(&1["_type"] == "Project")) == []
    end
  end

  test "find/2" do
    use_cassette "projects#find", match_requests_on: [:query] do
      {:ok, %QueryResult{results: projects}} = find(@client, "(Name = \"Training Sandbox\")")
      [%{"_refObjectName" => name}] = projects
      assert name == "Training Sandbox"

      {:ok, %QueryResult{results: projects}} = find(@client, "(Owner.LastName = Cartwright)")
      assert Enum.map(projects, &(&1["_refObjectName"])) == ["NewCo Products", "Data Architecture"]
    end
  end

  test "find/3" do
    use_cassette "projects#find_with_fetch" do
      {:ok, %QueryResult{results: projects}} = find(@client, "(Name = \"Training Sandbox\")", "Name,Description")
      [%{"Name" => name, "Description" => description}] = projects

      assert name == "Training Sandbox"
    end
  end

  test "read/2" do
    use_cassette "projects#read" do
      {:ok, %{"Project" => %{"_ref" => ref}}} = read(@client, @_ref)
      assert ref == @_ref
    end
  end
end
