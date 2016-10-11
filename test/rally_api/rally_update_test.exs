defmodule RallyApi.RallyUpdateTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.{TestHelper, RallyCreate, RallyUpdate}
  alias RallyApi.{Client, CreateResult, OperationResult}

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end

  test "update simple defect" do
    use_cassette "rally_update#simple_defect" do
      attrs = simple_defect_attributes
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

  test "update fails validation" do
    use_cassette "rally_update#fails_validation" do
      attrs = simple_defect_attributes
      {:ok, %CreateResult{object: defect}} = create(@client, :defect, attrs)

      object_id = defect["ObjectID"]
      attrs = %{"Defect" => %{"ScheduleState" => "In Progress"}} # valid value is "In-Progess"
      {:error, reason} = update(@client, :defect, object_id, attrs)

      assert reason =~ ~r/^Could not convert/
    end
  end
end
