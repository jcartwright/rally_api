defmodule RallyApi do
  use HTTPoison.Base
  alias RallyApi.{Client, QueryResult}

  def post(client, path, body \\ "", options \\ []) do
    headers = 
      client.auth
      |> authorization_header(custom_headers)

    result =
      client
      |> url(path)
      |> HTTPoison.post(body, headers)
  end

  def put(client, path, body \\ "", options \\ []) do
    headers = 
      client.auth
      |> authorization_header(custom_headers)

    result =
      client
      |> url(path)
      |> HTTPoison.put(body, headers)
  end

  def get(client, path, query \\ "", fetch \\ "", options \\ []) do
    headers = 
      client.auth
      |> authorization_header(custom_headers)

    result = 
      client
      |> url(path)
      |> append_query(query)
      |> append_fetch(fetch)
      |> append_options(options)
      |> get!(headers)
      |> QueryResult.to_result

    case result do
      %QueryResult{} = result ->
        if Enum.empty?(result.errors),
        do:   {:ok, result},
        else: {:error, Enum.at(result.errors, 0)}
      %HTTPoison.Response{status_code: 401} ->
        {:error, "Error 401 The username or password you entered is incorrect"}
      %{} = result ->
        {:ok, result}
    end
  end

  def delete(client, path) do
    headers = 
      client.auth
      |> authorization_header(custom_headers)

    result =
      client
      |> url(path)
      |> HTTPoison.delete(headers)
  end


  def get_security_token(client), do: get(client, "security/authorize")

  def get_security_token!(client) do
    case get_security_token(client) do
      {:ok, response} ->
        response["OperationResult"]["SecurityToken"]
      {:error, reason} -> raise reason
    end
  end

  def url(_client = %Client{endpoint: endpoint}, path) do
    cond do
      path =~ ~r/^#{endpoint}/ -> path # if path already contains endpoint, return it as-is
      true ->
        endpoint <> path
    end
  end

  def append_query(path, query) when query == "", do: path <> "?"

  def append_query(path, query) do
    path <> "?query=#{URI.encode(query)}"
  end

  def append_fetch(path, fetch) when fetch == "", do: path

  def append_fetch(path, fetch) do
    path <> "&fetch=#{URI.encode(fetch)}"
  end

  def append_options(path, []), do: path

  def append_options(path, options) do
    path <> "&" <> (
      compact_options(options)
      |> rallify_options
      |> URI.encode_query
    )
  end

  def rallify_options(options) do
    options
    |> Keyword.update(:workspace, nil, &("workspace/" <> (String.split(&1, "/") |> List.last)))
    |> Keyword.update(:project, nil, &("project/" <> (String.split(&1, "/") |> List.last)))
    |> Keyword.update(:order, nil, &(normalize_space(&1)))
    |> compact_options
  end

  def compact_options([]), do: []

  def compact_options(options) when is_list(options) do
    options
    |> Enum.filter(fn {_,v} -> v != nil end)
  end

  def normalize_space(text) when text == "", do: text

  def normalize_space(text) when is_binary(text) do
    text
    |> String.split(",")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.join(",")
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
    [{"X-RallyIntegrationPlatform", "Elixir 1.3.3"}, {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}]

    iex> RallyApi.custom_headers([{"X-RallyIntegrationName", "MyApp"}])
    [{"X-RallyIntegrationName", "MyApp"}, {"X-RallyIntegrationPlatform", "Elixir 1.3.3"}, {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}]

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
