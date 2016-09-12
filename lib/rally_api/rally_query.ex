defmodule RallyApi.RallyQuery do
  import RallyApi
  alias RallyApi.{Client, QueryResult}

  # def find(type, fetch, query, client, options \\ %{}) do
  #  %QueryResult{}
  # end

  def find(client, type, query) do
    case path_for(type) do
      {:ok, path} ->
        client
        |> get(path, query)
      {:error, reason} -> {:error, reason}
    end
  end

  def path_for(type) when is_atom(type) do
    case type do
      :story ->
        {:ok, "hierarchicalrequirement"}
      _ ->
        path_for "#{type}"
    end
  end

  def path_for(type), do: {:error, "#{type} is not a valid query type"}
end
