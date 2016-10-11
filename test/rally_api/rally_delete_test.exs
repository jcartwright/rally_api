defmodule RallyApi.RallyDeleteTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.{TestHelper, RallyCreate, RallyDelete}
  alias RallyApi.{Client, CreateResult, OperationResult}
  
  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end

  test "delete a defect" do
    use_cassette "rally_delete#delete_defect" do
      {:ok, %CreateResult{object: defect}} = create(@client, :defect, simple_defect_attributes)
      object_id = defect["ObjectID"]

      {:ok, %OperationResult{} = result} = delete(@client, :defect, object_id)
      assert result.object == nil

      query = "(ObjectID = #{object_id})"
      {:ok, %RallyApi.QueryResult{results: results}} = RallyApi.RallyQuery.find(@client, :defect, query)
      assert Enum.empty?(results)
    end
  end

  test "delete fails for unknown id" do
    use_cassette "rally_delete#unknown_id" do
      {:error, reason} = delete(@client, :defect, "this_is_not_valid")
      assert reason =~ ~r/^Could not read object/
    end
  end
end
