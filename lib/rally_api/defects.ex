defmodule RallyApi.Defects do
  import RallyApi.RallyQuery, only: [find: 5, read: 3]

  @doc """
  List all defects for the user's default workspace and project

  ## Examples:

    RallyApi.Defects.list(client)

  """
  def list(client), do: list(client, [])

  @doc """
  List all defects based on options provided, i.e. workspace or project

  ## Examples:

    RallyApi.Defects.list(client, project: "http://path/to/project/id")

  """
  def list(client, options) do
    find client, :defect, "", "Project", options
  end

  @doc """
  Find defects matching the params

  ## Examples:
  
    RallyApi.Defects.find(client, "(Priority = Normal)")

  """
  def find(client, query, fetch \\ "", options \\ []) do
    find client, :defect, query, fetch, options
  end

  @doc """
  Lookup a defect by its REST _ref url.

  ## Examples:

    RallyApi.Defects.read(client, "https://rally1.rallydev.com/slm/webservice/v2.0/defect/_defect_id_")

  """
  def read(client, ref), do: read(client, :defect, ref)

end

