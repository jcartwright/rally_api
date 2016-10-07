defmodule RallyApi.RallyUpdateTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.RallyCreate
  import RallyApi.RallyUpdate
  alias RallyApi.{Client, CreateResult, OperationResult}

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end

  test "update simple defect" do
    use_cassette "rally_update#simple_defect" do
      attrs = %{"Defect" =>
        %{"Name" => "Simple Defect for Update",
          "Priority" => "Normal",
          "c_CreationTeamName" => "Creation Team not assigned yet"}}
      {:ok, %CreateResult{object: defect}} = create(@client, :defect, attrs)

      object_id = defect["ObjectID"]
      attrs = %{"Defect" =>
        %{"Priority" => "High Attention",
          "c_Platform" => "Web",
          "ScheduleState" => "In-Progress"}}

      {:ok, %OperationResult{object: defect}} = update(@client, :defect, object_id, attrs)

      assert defect["Priority"] == "High Attention"
      assert defect["c_Platform"] == "Web"
      assert defect["ScheduleState"] == "In-Progress"
    end
  end
end
