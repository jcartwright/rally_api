defmodule RallyApi.Workspaces do
  import RallyApi
  alias RallyApi.RallyQuery

  @path RallyQuery.queryable_types[:workspace]

  @doc """
  List all workspaces for a user

  ## Example

    RallyApi.Workspaces.list(client)

  """
  def list(client) do
    get client, @path
  end

  @doc """
  Find workspaces matching the query and optional fetch

  ## Examples

    RallyApi.Workspaces.find(client, "(Name = NewCo)")
    RallyApi.Workspaces.find(client, "(Name = NewCo)", "Name,Description")

  """
  def find(client, query, fetch \\ "") do
    get client, @path, query, fetch
  end

  @doc """
  Lookup a workspace by its REST _ref url.

  ## Examples

    RallyApi.Workspaces.read(client, "https://rally1.rallydev.com/slm/webservice/v2.0/workspace/1234567890")

  """
  def read(client, ref) do
    # chomp the last element from the ref url and issue a get
    ref_id = ref
    |> String.split("/")
    |> List.last

    get client, "#{@path}/#{ref_id}"
  end
end
