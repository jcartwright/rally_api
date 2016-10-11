defmodule RallyApi.Defects do
  import RallyApi
  import RallyApi.Rallyties, only: [queryable_types: 0]
  alias RallyApi.RallyQuery

  @path queryable_types[:defect]

  @doc """
  List all defects for the user's default workspace and project

  ## Examples:

    RallyApi.Defects.list(client)

  """
  def list(client), do: list(client, [])

  def list(client, options) do
    get client, @path, "", "Project", options
  end
end
