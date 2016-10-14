defmodule RallyApi.RallyCollectionTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.{TestHelper, RallyCreate}
  import RallyApi.RallyCollection
  alias RallyApi.{Client, CreateResult, OperationResult, QueryResult}

  doctest RallyApi.RallyCollection
  
  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @artifact "https://rally1.rallydev.com/slm/webservice/v2.0/defect/67738776156"

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end

  test "read/3 with full _ref to artifact" do
    use_cassette "rally_collection#read_full_ref", match_requests_on: [:query] do
      {:ok, %QueryResult{} = result} = read(@client, @artifact, :tags)
      assert Enum.count(result.results) == result.total_result_count
    end
  end

  test "add tag to a defect" do
    use_cassette "rally_collection#add_tag_to_defect", match_requests_on: [:query] do
      {:ok, %CreateResult{object: tag}} = create(@client, :tag, %{"Name": "rally_api"})

      # add tag to the defect.tags collection
      {:ok, %OperationResult{results: results}} = add(@client, @artifact, :tags, %{"Name" => "rally_api"})
      assert Enum.any?(results, &(&1["_ref"] == tag["_ref"]))
    end
  end

  test "add tag to a defect by ref" do
    use_cassette "rally_collection#add_tag_to_defect_by_ref", match_requests_on: [:query] do
      {:ok, %CreateResult{object: tag}} = create(@client, :tag, %{"Name": "rally_api"})

      {:ok, %OperationResult{results: results}} = add(@client, @artifact, :tag, [%{"_ref" => tag["_ref"]}])
      assert Enum.any?(results, &(&1["_ref"] == tag["_ref"]))
    end
  end
end
