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

  @doc """
  Reads a Rally Object using type, _ref, and an optional fetch.

  If successful, it returns a naked Map with the type as the root key (i.e. %{"Defect" => %{...}}).

  If not successful, it returns a naked Map of an OperationResult (i.e. %{"OperationResult" => %{...}}),
  and a message in the Errors collection with details.
  """
  def read(client, type, ref, fetch \\ "") do
    ref_id = ref
      |> String.split("/")
      |> List.last

    case path_for(type) do
      {:ok, path} ->
        get client, "#{path}/#{ref_id}", "", fetch
      {:error, reason} ->
        {:error, reason}
    end
  end

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
