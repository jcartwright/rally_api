defmodule RallyApi.QueryResult do
  defstruct results: [], total_result_count: 0, warnings: [], errors: []

  @doc """
  Transform an %HTTPoison.Response into a %QueryResult
  """
  def to_result(%HTTPoison.Response{status_code: 200, body: body}) do
    body
    |> Poison.Parser.parse!
    |> to_result
  end

  def to_result(%{"QueryResult" => query_result}) do
    # IO.inspect query_result

    %RallyApi.QueryResult{
      errors:             query_result["Errors"],
      warnings:           query_result["Warnings"],
      total_result_count: query_result["TotalResultCount"],
      results:            query_result["Results"],
    }
  end

  # TODO: this is a hack and should probably not live in RallyApi.QueryResult
  # because it returns a simple Map and not a QueryResult struct.
  def to_result(%{} = query_result), do: query_result

end
