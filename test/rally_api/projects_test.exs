defmodule RallyApi.ProjectsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.Projects
  alias RallyApi.{Client, QueryResult}

  doctest RallyApi.Projects

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @_ref Application.get_env(:rally_api, :default_project)
  
  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end
  
  test "list/1" do
    use_cassette "projects#list" do
      {:ok, projects} = list(@client)
      refute Enum.empty?(projects.results)
      assert Enum.reject(projects.results, &(&1["_type"] == "Project")) == []
    end
  end

  test "find/2" do
    use_cassette "projects#find", match_requests_on: [:query] do
      {:ok, %QueryResult{results: projects}} = find(@client, "(Name = \"REST Toolkit for Elixir\")")
      [%{"_refObjectName" => name}] = projects
      assert name == "REST Toolkit for Elixir"

      {:ok, %QueryResult{results: projects}} = find(@client, "(Owner.LastName = Cartwright)")
      assert Enum.map(projects, &(&1["_refObjectName"])) == ["REST Toolkit for Elixir", "Sub Project 1", "Sub Project 2"]
    end
  end

  test "find/3" do
    use_cassette "projects#find_with_fetch" do
      {:ok, %QueryResult{results: projects}} = find(@client, "(Name = \"REST Toolkit for Elixir\")", "Name,Description")
      [%{"Name" => name, "Description" => description}] = projects

      assert name == "REST Toolkit for Elixir"
      assert description =~ ~r/^Develop a hex package in Elixir/
    end
  end

  test "find/4 scoped to workspace" do
    ws_ref = "https://rally1.rallydev.com/slm/webservice/v2.0/workspace/76001020136"

    use_cassette "projects#find_with_scope" do
      {:ok, %QueryResult{results: projects}} = find(@client, "", "Workspace", workspace: ws_ref)
      refute Enum.empty?(projects)
      assert Enum.reject(projects, &(&1["Workspace"]["_ref"] == ws_ref)) == []
    end
  end

  test "read/2" do
    use_cassette "projects#read" do
      {:ok, %{"Project" => %{"_ref" => ref}}} = read(@client, @_ref)
      assert ref == @_ref
    end
  end
end
