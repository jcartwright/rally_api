defmodule RallyApi.WorkspacesTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  
  import RallyApi.Workspaces
  alias RallyApi.{Client, QueryResult}

  doctest RallyApi.Workspaces

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @_ref "https://rally1.rallydev.com/slm/webservice/v2.0/workspace/52931496044"
  
  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end
  
  test "list/1" do
    use_cassette "workspaces#list" do
      {:ok, %QueryResult{results: workspaces}} = list(@client)

      assert workspaces == [%{"_rallyAPIMajor" => "2", "_rallyAPIMinor" => "0", 
          "_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/workspace/52931496044", 
          "_refObjectName" => "NewCo", "_refObjectUUID" => "ac74cbb3-2ddb-498f-b1a8-97a3d12c17aa", 
          "_type" => "Workspace"}]
    end
  end

  test "find/2" do
    use_cassette "workspaces#find" do
      {:ok, %QueryResult{results: workspaces}} = find(@client, "(Name = NewCo)")
      [%{"_refObjectName" => name}] = workspaces
      
      assert name == "NewCo"
    end
  end

  test "find/3" do
    use_cassette "workspaces#find_with_fetch" do
      {:ok, %QueryResult{results: workspaces}} = find(@client, "(Name = NewCo)", "Name,Description")
      [%{"Name" => name, "Description" => description}] = workspaces

      assert name == "NewCo"
      assert description == "This is the workspace for the new, combined organization"
    end
  end

  test "read/2" do
    use_cassette "workspaces#read" do
      {:ok, %{"Workspace" => %{"_ref" => ref}}} = read(@client, @_ref)
      assert ref == @_ref
    end
  end
end
