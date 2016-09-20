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
      |> append_options(options)
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
    # TODO: |> camelize_options
    |> compact_options
  end

  def compact_options([]), do: []

  def compact_options(options) when is_list(options) do
    options
    |> Enum.filter(fn {k,v} -> v != nil end)
  end

  def normalize_space(text) when text == "", do: text

  def normalize_space(text) when is_binary(text) do
    text
    |> String.split(",")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.join(",")
  end

  # Rally will ignore these options unless they are camelCase, so I'm punting on this
  # because it's just as easy to pass the options as :projectScopeUp and :projectScopeDown
  # def camelize_options(options) do
    # Keyword.take(options, [:project_scope_up, :project_scope_down])
    # |> Enum.map(fn {k, v} -> { Atom.to_string(k) |> Macro.camelize |> String.to_atom, v } end)
    # |> Keyword.merge(options)
    # |> Keyword.drop([:project_scope_up, :project_scope_down])
  # end

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
