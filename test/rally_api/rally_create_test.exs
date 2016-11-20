defmodule RallyApi.RallyCreateTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import RallyApi.RallyCreate
  alias RallyApi.{Client, CreateResult}

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})

  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end

  test "create simple defect" do
    use_cassette "rally_create#simple_defect" do
      type = :defect
      attrs = %{
        "Name" => "Simple Defect via RallyRestToolkitForElixir",
        "Priority" => "Normal",
      }

      {:ok, %CreateResult{object: defect}} = create(@client, type, attrs)
      assert defect["Name"] == attrs["Name"]
      assert defect["Priority"] == attrs["Priority"]
    end
  end

  test "create fails on required field" do
    use_cassette "rally_create#fails_on_required_field" do
      type = :defect
      attrs = %{}

      {:error, reason} = create(@client, type, attrs)
      assert reason =~ ~r/^Validation error/
    end
  end

  test "create fails with invalid workspace" do
    use_cassette "rally_create#fails_with_invalid_workspace" do
      type = :defect
      attrs = %{
        "Defect" => %{
          "Name" => "Simple Defect with Workspace Scope",
          "Workspace" => %{"_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/workspace/0000000001"}
        }
      }

      {:error, reason} = create(@client, type, attrs)
      assert reason =~ ~r/Could not read referenced object/
    end
  end

  test "create fails with invalid project" do
    use_cassette "rally_create#fails_with_invalid_project" do
      type = :defect
      attrs = %{
        "Defect" => %{
          "Name" => "Simple Defect with Project Scope",
          "Project" => %{"_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/project/0000000001"}
        }
      }

      {:error, reason} = create(@client, type, attrs)
      assert reason =~ ~r/Could not read referenced object/
    end
  end
  
  test "create with project scope" do
    use_cassette "rally_create#defect_with_project_scope" do
      project_ref = "https://rally1.rallydev.com/slm/webservice/v2.0/project/76175116672"
      type = :defect
      attrs = %{
        "Name" => "Simple Defect with Project Scope",
        "Project" => %{"_ref" => project_ref}
      }

      {:ok, %CreateResult{object: defect}} = create(@client, type, attrs)
      assert defect["Project"]["_ref"] == project_ref
    end
  end
end
