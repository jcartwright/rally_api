defmodule RallyApi.RallyCollectionTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.{RallyCreate}
  import RallyApi.RallyCollection
  alias RallyApi.{Client, CreateResult, OperationResult, QueryResult}

  doctest RallyApi.RallyCollection
  
  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @artifact "https://rally1.rallydev.com/slm/webservice/v2.0/defect/76006760256"

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

  test "find/6" do
    use_cassette "rally_collection#find_with_text", match_requests_on: [:query] do
      {:ok, result} = add(@client, @artifact, :discussion, [%{"Text" => "#{__MODULE__}"}])

      query = "(Text contains \"#{__MODULE__}\")"
      {:ok, %QueryResult{results: results}} = find(@client, @artifact, :discussion, query)
      assert Enum.all?(results, &(&1["Text"] =~ ~r/#{__MODULE__}/))
    end
  end

  test "add tag to a defect" do
    use_cassette "rally_collection#add_tag_to_defect", match_requests_on: [:query] do
      {:ok, %CreateResult{object: tag}} = create(@client, :tag, %{"Name": "rally_api"})

      # add tag to the defect.tags collection
      {:ok, %OperationResult{results: results}} = add(@client, @artifact, :tags, [%{"Name" => "rally_api"}])
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

  test "remove tag from defect" do
    use_cassette "rally_collection#remove_tag_from_defect", match_requests_on: [:query] do
      # add tag 'rally_api' to defect
      {:ok, %OperationResult{results: tags}} = add(@client, @artifact, :tags, [%{"Name" => "rally_api"}])
      tag = Enum.at(tags, 0)

      # remove the tag
      {:ok, _result} = remove(@client, @artifact, :tags, [%{"_ref" => tag["_ref"]}])

      # re-read the defect.tags collection
      {:ok, %QueryResult{results: tags}} = read(@client, @artifact, :tags)
      assert Enum.empty?(tags)
    end
  end
end
