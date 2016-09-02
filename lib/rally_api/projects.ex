defmodule RallyApi.Projects do
  import RallyApi
  alias RallyApi.Client

  @doc """
  List all projects _for a workspace_

  ## Example

    RallyApi.Projects.list(client)

  """
  def list(client \\ %Client{}) do
    get "project", client
  end

  @doc """
  Find projects matching the params

  ## Examples

    RallyApi.Projects.find(%{name: "Training Sandbox"}, client)
    RallyApi.Projects.find(%{_ref: "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530"}, client)

  """
  def find(query, client) do
    get "project", client, query
  end

  @doc """
  Lookup a project by its REST _ref url.

  ## Examples

    RallyApi.Projects.read("https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530", client)
  """
  def read(ref, client) do
    # chomp the last element from the ref url and issue a get
    ref_id = ref
    |> String.split("/")
    |> List.last

    get "project/#{ref_id}", client
  end
end
