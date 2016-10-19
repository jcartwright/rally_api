defmodule RallyApi.RallyDelete do
  import RallyApi
  import RallyApi.Rallyties, only: [deleteable_types: 0]

  alias RallyApi.OperationResult

  def delete(client, type, object_id) do
    case path_for(type, object_id) do
      {:ok, path} ->
        case delete(client, path) do
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
