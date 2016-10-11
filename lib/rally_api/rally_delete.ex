defmodule RallyApi.RallyDelete do
  import RallyApi

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

  defp path_for(type, object_id) do
    {:ok, "#{type}/#{object_id}"}
  end
end
