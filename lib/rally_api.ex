defmodule RallyApi do
  use HTTPoison.Base
  alias RallyApi.{Client, QueryResult}

  def get(client, path, query \\ "", fetch \\ "", options \\ []) do
    headers = 
      client.auth
      |> authorization_header(custom_headers)

    result = 
      client
      |> url(path)
      |> append_query(query)
      |> append_fetch(fetch)
      |> get!(headers)
      |> QueryResult.to_result

    case result do
      %QueryResult{} = result ->
        if Enum.empty?(result.errors),
        do:   {:ok, result},
        else: {:error, Enum.at(result.errors, 0)}
      %{} = result ->
        {:ok, result}
    end
  end

  def url(_client = %Client{endpoint: endpoint}, path) do
    endpoint <> path
  end

  def append_query(path, query) when query == "", do: path

  def append_query(path, query) do
    path <> "?query=#{URI.encode(query)}"
  end

  def append_fetch(path, fetch) when fetch == "", do: path

  def append_fetch(path, fetch) do
    path <> "&fetch=#{URI.encode(fetch)}"
  end

  @doc """
  There are two ways to authenticate through the Rally REST API v2:

    * Basic authentication
    * API Key

  This function accepts both.

  ## Examples

    iex> RallyApi.authorization_header(%{user: "user", password: "password"}, [])
    [{"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}]

    iex> RallyApi.authorization_header(%{zsessionid: "0192837465"}, [])
    [{"ZSESSIONID", "0192837465"}]

  ## More info
  https://rally1.rallydev.com/slm/doc/webservice/authentication.jsp
  """
  def authorization_header(%{user: user, password: password}, headers) do
    userpass = "#{user}:#{password}"
    headers ++ [{"Authorization", "Basic #{:base64.encode(userpass)}"}]
  end

  def authorization_header(%{zsessionid: api_key}, headers) do
    headers ++ [{"ZSESSIONID", api_key}]
  end

  def authorization_header(_, headers), do: headers

  @doc """
  The Rally API collects non-proprietary and non-confidential information to track usage patterns and improve their products.

  ## Examples

    iex> RallyApi.custom_headers
    [{"X-RallyIntegrationPlatform", "Elixir 1.3.2"}, {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}]

    iex> RallyApi.custom_headers([{"X-RallyIntegrationName", "MyApp"}])
    [{"X-RallyIntegrationName", "MyApp"}, {"X-RallyIntegrationPlatform", "Elixir 1.3.2"}, {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}]

  ## More info
  https://rally1.rallydev.com/slm/doc/webservice/clientinfo.jsp
  """
  def custom_headers(custom, headers \\ custom_headers) when is_list(custom) do
    custom ++ headers
  end

  def custom_headers do
    _defaults = [
      {"X-RallyIntegrationPlatform", "Elixir #{System.version}"},
      {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}
    ]
  end
end
