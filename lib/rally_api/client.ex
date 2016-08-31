defmodule RallyApi.Client do
  defstruct auth: nil, endpoint: "https://rally1.rallydev.com/slm/webservice/v2.0/"

  def new(), do: %__MODULE__{}

  def new(auth), do: %__MODULE__{auth: auth}

  def new(auth, endpoint) do
    endpoint = if String.ends_with?(endpoint, "/") do
      endpoint
    else
      endpoint <> "/"
    end
    %__MODULE__{auth: auth, endpoint: endpoint}
  end
end
