defmodule RallyApi.RallyUpdate do
  import RallyApi
  import RallyApi.Rallyties

  alias RallyApi.OperationResult

  def update(client, type, object_id, attributes, options \\ []) do
    case path_for(type, object_id) do
      {:ok, path} ->
        object = type
          |> wrap_attributes_with_rally_type(attributes)
          |> Poison.encode!

        case post(client, path, object, options) do
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
