defmodule RallyApi.Projects do
  import RallyApi
  alias RallyApi.RallyQuery

  @path RallyQuery.queryable_types[:project]

  @doc """
  List all projects _for a workspace_

  ## Example

    RallyApi.Projects.list(client)

  """
  def list(client) do
    get client, @path
  end

  @doc """
  Find projects matching the params

  ## Examples

    RallyApi.Projects.find(client, "(Name = \"Training Sandbox\")")

  """
  def find(client, query, fetch \\ "") do
    get client, @path, query, fetch
  end

  @doc """
  Lookup a project by its REST _ref url.

  ## Examples

    RallyApi.Projects.read(client, "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530")

  """
  def read(client, ref) do
    # chomp the last element from the ref url and issue a get
    ref_id = ref
    |> String.split("/")
    |> List.last

    get client, "#{@path}/#{ref_id}"
  end
end
