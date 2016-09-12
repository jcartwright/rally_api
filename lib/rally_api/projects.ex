defmodule RallyApi.Projects do
  import RallyApi
  alias RallyApi.Client

  @doc """
  List all projects _for a workspace_

  ## Example

    RallyApi.Projects.list(client)

  """
  def list(client \\ %Client{}) do
    get client, "project"
  end

  @doc """
  Find projects matching the params

  ## Examples

    RallyApi.Projects.find(client, %{name: "Training Sandbox"})
    RallyApi.Projects.find(client, %{_ref: "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530"})

  """
  def find(client, query) do
    get client, "project", query
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

    get client, "project/#{ref_id}"
  end
end
