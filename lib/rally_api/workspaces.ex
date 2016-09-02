defmodule RallyApi.Workspaces do
  import RallyApi
  alias RallyApi.Client

  @doc """
  List all workspaces for a user

  ## Example

    RallyApi.Workspaces.list(client)

  """
  def list(client \\ %Client{}) do
    get "workspace", client
  end
end
