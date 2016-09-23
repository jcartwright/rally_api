defmodule RallyApi.CreateResult do
  defstruct object: %{}, warnings: [], errors: []

  @doc """
  Transform an %HTTPoison.Response into a %CreateResult
  """
  def to_result(%HTTPoison.Response{status_code: 200, body: body}) do
    body
    |> Poison.Parser.parse!
    |> to_result
  end

  def to_result(%{"CreateResult" => create_result}) do
    %RallyApi.CreateResult{
      errors:   create_result["Errors"],
      warnings: create_result["Warnings"],
      object:   create_result["Object"],
    }
  end
end
