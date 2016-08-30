defmodule RallyApi do
  # alias RallyApi.Client

  def authorization_header(%{user: user, password: password}, headers) do
    userpass = "#{user}:#{password}"
    headers ++ [{"Authorization", "Basic #{:base64.encode(userpass)}"}]
  end

  def authorization_header(%{zsessionid: api_key}, headers) do
    headers ++ [{"ZSESSIONID", api_key}]
  end

  def authorization_header(_, headers), do: headers
end
