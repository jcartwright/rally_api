defmodule RallyApi.OperationResult do
  defstruct object: %{}, warnings: [], errors: []

  @doc """
  Transform an %HTTPoison.Response into a %OperationResult
  """
  def to_result(%HTTPoison.Response{status_code: 200, body: body}) do
    body
    |> Poison.Parser.parse!
    |> to_result
  end

  def to_result(%{"OperationResult" => op_result}) do
    %RallyApi.OperationResult{
      errors:   op_result["Errors"],
      warnings: op_result["Warnings"],
      object:   op_result["Object"]
    }
  end
end
