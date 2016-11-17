defmodule RallyApi.Client do
  defstruct auth: nil, workspace: nil, endpoint: "https://rally1.rallydev.com/slm/webservice/v2.0/"

  def new(), do: %__MODULE__{}

  def new(%{} = config) do
    new(Enum.to_list(config), %__MODULE__{})
  end

  def new([{:auth, auth} | rest], client) do
    new(rest, %__MODULE__{client | auth: auth})
  end
  
  def new([{:zsessionid, auth} | rest], client) do
    new(rest, %__MODULE__{client | auth: %{zsessionid: auth}})
  end
  
  def new([{:workspace, workspace} | rest], client) do
    new(rest, %__MODULE__{client | workspace: workspace})
  end
  
  def new([{:endpoint, endpoint} | rest], client) do
    new(rest, %__MODULE__{client | endpoint: endpoint})
  end

  def new([_|rest], client) do
    new(rest, client)
  end

  def new([], client), do: client
end
