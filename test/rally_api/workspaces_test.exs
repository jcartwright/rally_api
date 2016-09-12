defmodule RallyApi.WorkspacesTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import RallyApi.Workspaces

  doctest RallyApi.Workspaces

  @client RallyApi.Client.new(%{zsessionid: "_lopoalp1TxyqCH3p7s1FWco2ROI90uxpii7ubJYH8"})

  setup_all do
    HTTPoison.start
  end

  test "list/1" do
    use_cassette "workspaces#list" do
      {:ok, result} = list(@client)

      assert %RallyApi.QueryResult{} = result
      assert result.results == [
        %{"_rallyAPIMajor" => "2", "_rallyAPIMinor" => "0", 
          "_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/workspace/52931496044", 
          "_refObjectName" => "NewCo", "_refObjectUUID" => "ac74cbb3-2ddb-498f-b1a8-97a3d12c17aa", 
          "_type" => "Workspace"}
      ]
    end
  end

  @tag :pending
  test "find/#" do
    assert false
  end
end
