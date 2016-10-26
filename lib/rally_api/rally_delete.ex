defmodule RallyApi.RallyDelete do
  # DO NOT import RallyApi - this causes an import conflict for delete/2
  import RallyApi.Rallyties, only: [deleteable_types: 0]

  alias RallyApi.OperationResult

  @doc """
  Deletes a Rally Object using the `_ref` provided

  ## Examples:

    RallyApi.RallyDelete.delete(client, "https://path/to/object/_object_id")

  """
  def delete(client, ref) do
    case RallyApi.delete(client, ref) do
      {:ok, response} ->
        result = OperationResult.to_result(response)
        if Enum.empty?(result.errors),
        do:   {:ok, result},
        else: {:error, Enum.at(result.errors, 0)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a Rally Object by specifying type and the ObjectID

  ## Examples:

    RallyApi.RallyDelete.delete(client, :defect, 123456789)

  """
  def delete(client, type, object_id) do
    case path_for(type, object_id) do
      {:ok, path} ->
        case RallyApi.delete(client, path) do
          {:ok, response} ->
            result = OperationResult.to_result(response)
            if Enum.empty?(result.errors),
            do:   {:ok, result},
            else: {:error, Enum.at(result.errors, 0)}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp path_for(type, object_id) when is_binary(type), do: path_for(String.to_atom(type), object_id)

  defp path_for(type, object_id) when is_atom(type) do
    cond do
      path = deleteable_types[type] ->
        {:ok, "#{path}/#{object_id}"}
      true ->
        {:error, ":#{type} is not a deleteable type"}
    end
  end
end
