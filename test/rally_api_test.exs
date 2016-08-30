defmodule RallyApiTest do
  use ExUnit.Case
  import RallyApi

  doctest RallyApi

  test "authorization_header using user and password" do
    assert authorization_header(%{user: "user", password: "password"}, []) == [{"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}]
  end

  test "authorization_header using api key" do
    assert authorization_header(%{zsessionid: "ZSESSIONID"}, []) == [{"ZSESSIONID", "ZSESSIONID"}]
  end

  test "authorization_header pass-through" do
    headers = [{"X-RallyIntegrationName", "RallyRestToolkitForElixir"}]
    assert authorization_header(%{unknown: "barbaz"}, [{"X-RallyIntegrationName", "RallyRestToolkitForElixir"}]) == headers
  end
end
