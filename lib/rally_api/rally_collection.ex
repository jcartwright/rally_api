defmodule RallyApi.RallyCollection do
  import RallyApi
  import RallyApi.Rallyties, only: [collectable_types: 0, wrap_attributes_with_rally_type: 2]

  alias RallyApi.OperationResult

  @doc """
  Returns the collection specified for the given artifact
  """
  def read(client, artifact, collection_type) do
    case collection_path_for(collection_type) do
      {:ok, collection_path} ->
        get client, "#{artifact}/#{collection_path}"
      {:error, reason} ->
        {:error, reason}
    end
  end

  def find(client, artifact, collection_type, query, fetch \\ "", options \\ []) do
    raise "Not implemented" 
  end

  def add(client, artifact, collection_type, items) when is_list(items) do
    add(client, artifact, collection_type, %{"CollectionItems" => items})
  end

  def add(client, artifact, collection_type, items) when is_map(items) do
    case collection_path_for(collection_type) do
      {:ok, path} ->
        attrs = wrap_attributes_with_rally_type(:collection_items, items)
        result = post(client, "#{artifact}/#{path}/add", Poison.encode!(attrs))
          |> OperationResult.to_result

        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def add(client, artifact, collection_type, item), do: add(client, artifact, collection_type, [item])

  def update(client, artifact, collection_type, items) when is_list(items) do

  end
  
  def update(client, artifact, collection_type, item), do: update(client, artifact, collection_type, [item])

  def collection_path_for(collection_type) when is_binary(collection_type), 
  do: collection_path_for(String.to_atom(collection_type))

  def collection_path_for(collection_type) do
    cond do
      path = collectable_types[collection_type] ->
        {:ok, path}
      true ->
        {:error, ":#{collection_type} is not a valid collectable type"}
    end
  end
end
