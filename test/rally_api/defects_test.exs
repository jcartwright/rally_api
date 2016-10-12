defmodule RallyApi.DefectsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.Defects
  alias RallyApi.{Client, QueryResult}

  doctest RallyApi.Defects

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @_ref "https://rally1.rallydev.com/slm/webservice/v2.0/defect/54626752843"
  @project "https://rally1.rallydev.com/slm/webservice/v2.0/project/55700974877"

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

      p_id = "https://rally1.rallydev.com/slm/webservice/v2.0/project/55700976506"
      {:ok, %QueryResult{results: defects}} = list(@client, project: p_id)
      assert Enum.empty?(defects)
    end
  end

  test "find/3 query on priority" do
    use_cassette "defects#find_with_priority" do
      {:ok, %QueryResult{} = result} = find(@client, "(Priority = \"High Attention\")", "Priority")
      assert result.total_result_count == 40
      assert result.results |> Enum.reject(&(&1["Priority"] == "High Attention")) |> Enum.empty?
    end
  end

  test "read/2" do
    use_cassette "defects#read" do
      {:ok, %{"Defect" => %{"_ref" => ref}}} = read(@client, @_ref)
      assert ref == @_ref
    end
  end
end
