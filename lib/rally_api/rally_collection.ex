defmodule RallyApi.RallyCollection do
  import RallyApi
  import RallyApi.Rallyties, only: [collectable_types: 0, wrap_attributes_with_rally_type: 2]

  alias RallyApi.OperationResult

  @doc """
  Returns the collection specified for the given artifact

  ## Examples:
  ```
    RallyApi.RallyCollection.read(client, "https://path/to/artifact/_object_id_", :tags)
    RallyApi.RallyCollection.read(client, "https://path/to/artifact/_object_id_", :discussion)
  ```
  """
  def read(client, artifact, collection_type) do
    case collection_path_for(collection_type) do
      {:ok, collection_path} ->
        get client, "#{artifact}/#{collection_path}"
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Query for items in a collection belonging to _artifact_

  ## Examples:
  ```
    RallyApi.RallyCollection.find(client, "http://path/to/artifact/_object_id_", :tags, "(Name = rally_api)")
  ```
  """
  def find(client, artifact, collection_type, query, fetch \\ "", options \\ []) do
    case collection_path_for(collection_type) do
      {:ok, collection_path} ->
        get client, "#{artifact}/#{collection_path}", query, fetch, options
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Adds a list of items to the specified collection on the target artifact.

  ## Examples:
  ```
    RallyApi.RallyCollection.add(client, "https://path/to/artifact/_object_id_", :tags, [%{"Name" => "rally_api"}])
  ```
  """
  def add(client, artifact, collection_type, items) when is_list(items) do
    add(client, artifact, collection_type, %{"CollectionItems" => items})
  end

  @doc """
  Adds items in the `Map` to to specified collection on the target artifact.

  ## Examples:
  ```
    RallyApi.RallyCollection.add(client, "https://path/to/artifact/_object_id_", :tags, 
      %{"CollectionItems" => [
        %{"_ref" => "https://path/to/tag/_object_id_"},
        %{"_ref" => "https://path/to/tag/_object_id_"}
      ]}
    )
  ```
  """
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

  @doc """
  Removes a list of items from the specified collection on the target artifact.

  *Note:* Remove will only work with `_ref` parameters, and not other fields like `Name`

  ## Examples:
  ```
    RallyApi.RallyCollection.remove(client, "https://path/to/artifact/_object_id_", :tags, 
      [%{"_ref" => "https://path/to/tag/_object_id_"}]
    )
  ```
  """
  def remove(client, artifact, collection_type, items) when is_list(items) do
    remove(client, artifact, collection_type, %{"CollectionItems" => items})
  end

  @doc """
  Removes items in the `Map` from the specified collection on the target artifact.

  *Note:* Remove will only work with `_ref` parameters, and not other fields like `Name`

  ## Examples:
  ```
    RallyApi.RallyCollection.remove(client, "https://path/to/artifact/_object_id_", :tags, 
      %{CollectionItems" => [
        %{"_ref" => "https://path/to/tag/_object_id_"},
        %{"_ref" => "https://path/to/tag/_object_id_"}
      ]}
    )
  ```
  """
  def remove(client, artifact, collection_type, items) when is_map(items) do
    case collection_path_for(collection_type) do
      {:ok, path} ->
        attrs = wrap_attributes_with_rally_type(:collection_items, items)
        result = post(client, "#{artifact}/#{path}/remove", Poison.encode!(attrs))
          |> OperationResult.to_result
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp collection_path_for(collection_type) when is_binary(collection_type), 
  do: collection_path_for(String.to_atom(collection_type))

  defp collection_path_for(collection_type) do
    cond do
      path = collectable_types[collection_type] ->
        {:ok, path}
      true ->
        {:error, ":#{collection_type} is not a valid collectable type"}
    end
  end
end
