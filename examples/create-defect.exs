# This is an example of creating a defect in Rally
# Setup:
# - Make sure you have a config/dev.exs file with a valid API key or user/password
# - Replace @project_ref with a valid project
# - Replace username with a valid email/username
#
# $ mix run examples/create-defect.exs
defmodule CreateDefect do
  alias RallyApi.{Client, Rallyties}
  alias RallyApi.{RallyCreate, CreateResult}
  alias RallyApi.{RallyDelete, RallyUpdate, OperationResult}
  alias RallyApi.{RallyQuery, QueryResult}

  import Rallyties, only: [get_ref: 1]

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @project_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/OBJECT_ID"

  def main do
    # Setup a basic Defect in the target Project
    attrs = %{
      "Defect" => %{
        "Name" => "Example Defect", 
        "Priority" => "High Attention", 
        "Project" => %{"_ref" => @project_ref},
      }
    }

    case RallyCreate.create(@client, :defect, attrs) do
      {:ok, %CreateResult{object: defect}} ->
        # Display the Defect
        show_defect(defect)

        # Set the Owner & Schedule State on the defect
        username = "jason@example.com"
        {:ok, %QueryResult{results: users}} = RallyQuery.find(
          @client, :user, "(UserName = \"#{username}\")", "UserName,EmailAddress")

        changes = %{"Defect" => %{
            "Owner" => %{"_ref" => Enum.at(users, 0) |> get_ref},
            "ScheduleState" => "In-Progress",
          }
        }

        IO.puts "Updating defect..."

        {:ok, %OperationResult{object: defect}} = RallyUpdate.update(
          @client, :defect, defect["ObjectID"], changes)
        
        :timer.sleep(1000) # give time for the update to complete
        
        # Redisplay the Defect
        {:ok, %{"Defect" => defect}} = RallyQuery.read(
          @client, :defect, get_ref(defect), "Name,Priority,ScheduleState,Owner")
        
        show_defect(defect)

        # Clean up
        IO.puts "Cleaning up..."
        delete_defect(defect)
      {:error, reason} ->
        IO.puts reason
    end
  end

  defp show_defect(defect) do
    fields = ["Name", "Priority", "ScheduleState"]

    IO.puts "-----------------------------------------------"
    IO.puts "| Field                | Value                |"

    fields
    |> Enum.each(fn(key) ->
      IO.puts "-----------------------------------------------"
      IO.puts "| #{String.pad_trailing(key, 20)} | #{Map.get(defect, key, "") |> String.pad_trailing(20)} |"
    end)

    IO.puts "-----------------------------------------------"
    Map.get(defect, "Owner", "(null)") |> display_owner

    IO.puts "==============================================="
  end

  defp display_owner(owner) when is_binary(owner) do
    IO.puts "| #{String.pad_trailing("Owner", 20)} | #{String.pad_trailing(owner, 20)} |"
  end

  defp display_owner(owner) when is_list(owner), do: display_owner(Enum.at(owner, 0))

  defp display_owner(owner) when is_map(owner), do: display_owner(Map.get(owner, "_refObjectName", ""))

  defp display_owner(_owner), do: display_owner("(null)")

  defp delete_defect(defect) do
    RallyDelete.delete(@client, get_ref(defect))
  end
end


IO.puts "Create a Defect in Rally"
IO.puts "------------------------"

CreateDefect.main

IO.puts "DONE"

