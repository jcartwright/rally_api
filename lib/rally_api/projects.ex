defmodule RallyApi.Projects do
  import RallyApi.RallyQuery, only: [find: 5, read: 3]

  @doc """
  List all projects in the user's default workspace

  ## Example:

    RallyApi.Projects.list(client)

  """
  def list(client), do: list(client, [])

  @doc """
  List all projects based on options provided, i.e. workspace

  ## Example:

    RallyApi.Projects.list(client, workspace: "http://path/to/workspace/_workspace_id_")

  """
  def list(client, options) do
    find client, :project, "", "", options
  end

  @doc """
  Find projects matching the params

  ## Examples:

    RallyApi.Projects.find(client, "(Name = \"Training Sandbox\")")
    RallyApi.Projects.find(client, "(Name = \"Training Sandbox\")", "Name,Description")
    RallyApi.Projects.find(client, "(Name = \"Training Sandbox\")", "", project: "http://path/to/project/_project_id_")

  """
  def find(client, query, fetch \\ "", options \\ []) do
    find client, :project, query, fetch, Keyword.take(options, [:workspace, :order])
  end

  @doc """
  Lookup a project by its REST _ref url.

  ## Examples:

    RallyApi.Projects.read(client, "https://rally1.rallydev.com/slm/webservice/v2.0/project/_project_id_")

  """
  def read(client, ref), do: read(client, :project, ref)

end
