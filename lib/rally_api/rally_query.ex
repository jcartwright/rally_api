defmodule RallyApi.RallyQuery do
  import RallyApi
  import RallyApi.Rallyties, only: [queryable_types: 0]

  def find(client, type, query, fetch, options \\ []) do
    case path_for(type) do
      {:ok, path} ->
        client
        |> get(path, query, fetch, options)
      {:error, reason} -> {:error, reason}
    end
  end

  def find(client, type, query), do: find(client, type, query, "")

  def find(client, type), do: find(client, type, "")

  def path_for(type) when is_binary(type), do: path_for(String.to_atom(type))

  def path_for(type) when is_atom(type) do
    cond do
      path = queryable_types[type] ->
        {:ok, path}
      true ->
        {:error, ":#{type} is not a valid query type"}
    end
  end

end
