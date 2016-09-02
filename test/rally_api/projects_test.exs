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
      projects = list(@client)
      refute Enum.empty?(projects)
      assert Enum.reject(projects, &(&1["_type"] == "Project")) == []
    end
  end

  test "find/2 query, client" do
    use_cassette "projects#find" do
      [%{"_refObjectName" => name}] = find("(Name = \"Training Sandbox\")", @client)
      assert name == "Training Sandbox"
    end
  end

  @tag :wip
  test "read/2 _ref, client" do
    use_cassette "projects#read" do
      %{"Project" => %{"_ref" => ref}} = read(@_ref, @client)
      assert ref == @_ref
    end
  end
end
