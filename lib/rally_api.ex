defmodule RallyApi do
  use HTTPoison.Base
  alias RallyApi.Client

  def get(path, client, query \\ "", fetch \\ false, options \\ []) do
    url = 
      client
      |> url(path)
      |> append_query(query)

    # IO.inspect url

    headers = authorization_header(
      client.auth, custom_headers)

    case HTTPoison.get(url, headers) do
      {:ok, resp} ->
        resp.body
        |> Poison.Parser.parse!
        |> extract_results
      {:error, reason} ->
        IO.puts "Error: #{reason}"
        []
    end
  end

  defp url(_client = %Client{endpoint: endpoint}, path) do
    endpoint <> path
  end

  defp append_query(path, query) when query == "", do: path

  defp append_query(path, query) do
    path <> "?query=#{URI.encode(query)}"
  end

  defp extract_results(%{"QueryResult" => query_result} = resp) do
    resp["QueryResult"]["Results"]
  end

  defp extract_results(resp), do: resp

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
