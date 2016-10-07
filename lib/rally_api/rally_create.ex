defmodule RallyApi.RallyCreate do
  import RallyApi
  import RallyApi.Rallyties, only: [createable_types: 0, wrap_attributes_with_rally_type: 2]

  alias RallyApi.CreateResult

  def create(client, type, attributes, options \\ []) do
    case path_for(type) do
      {:ok, path} ->
        object = type
          |> wrap_attributes_with_rally_type(attributes)
          |> Poison.encode!

        case post(client, path, object, options) do
          {:ok, response} ->
            result = CreateResult.to_result(response)
            if Enum.empty?(result.errors),
            do:   {:ok, result},
            else: {:error, Enum.at(result.errors, 0)}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def path_for(type) when is_binary(type), do: path_for(String.to_atom(type))

  def path_for(type) when is_atom(type) do
    cond do
      path = createable_types[type] ->
        {:ok, path <> "/create"}
      true ->
        {:error, ":#{type} is not a createable type"}
    end
  end

end
