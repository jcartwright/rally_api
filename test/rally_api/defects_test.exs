defmodule RallyApi.DefectsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.{TestHelper, Defects}
  alias RallyApi.{Client, CreateResult, QueryResult}

  doctest RallyApi.Defects

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @project Application.get_env(:rally_api, :default_project)

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end

  test "list/1" do
    use_cassette "defects#list" do
      {:ok, defects} = list(@client)
      refute Enum.empty?(defects.results)
      assert Enum.reject(defects.results, &(&1["_type"] == "Defect")) |> Enum.empty?
    end
  end

  test "list with project scope" do
    use_cassette "defects#list_scoped_to_project", match_requests_on: [:query] do
      {:ok, %QueryResult{results: defects}} = list(@client, project: @project)
      assert defects |> Enum.map(&(&1["Project"]["_ref"])) |> Enum.uniq == [@project]

      p_id = "https://rally1.rallydev.com/slm/webservice/v2.0/project/76175119612"
      {:ok, %QueryResult{results: defects}} = list(@client, project: p_id)
      assert Enum.empty?(defects)
    end
  end

  test "find/3 query on priority" do
    use_cassette "defects#find_with_priority" do
      {:ok, %QueryResult{} = result} = find(@client, "(Priority = \"High Attention\")", "Priority")
      assert result.total_result_count > 0
      assert result.results |> Enum.reject(&(&1["Priority"] == "High Attention")) |> Enum.empty?
    end
  end

  test "read/2" do
    use_cassette "defects#read" do
      {:ok, %CreateResult{object: defect}} = RallyApi.RallyCreate.create(@client, :defect, simple_defect_attributes)
      ref = defect["_ref"]
      {:ok, %{"Defect" => %{"_ref" => read_ref}}} = read(@client, ref)
      assert read_ref == ref
    end
  end
end
