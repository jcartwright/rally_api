defmodule RallyApiTest do
  use ExUnit.Case
  import RallyApi

  doctest RallyApi

  test "authorization_header using user and password" do
    assert authorization_header(%{user: "user", password: "password"}, []) == [{"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}]
  end

  test "authorization_header from client.auth with username and password" do
    client = RallyApi.Client.new(%{auth: %{user: "user", password: "password"}})
    assert authorization_header(client.auth, []) == [{"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}]
  end

  test "authorization_header using api key" do
    assert authorization_header(%{zsessionid: "ZSESSIONID"}, []) == [{"ZSESSIONID", "ZSESSIONID"}]
  end

  test "authorization_header pass-through" do
    headers = [{"X-RallyIntegrationName", "RallyRestToolkitForElixir"}]
    assert authorization_header(%{unknown: "barbaz"}, [{"X-RallyIntegrationName", "RallyRestToolkitForElixir"}]) == headers
  end

  test "custom_headers with defaults" do
    defaults = [
      {"X-RallyIntegrationPlatform", "Elixir #{System.version}"},
      {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}
    ]
    assert custom_headers() == defaults
  end

  test "custom_headers with overrides" do
    custom = [
      {"X-RallyIntegrationName", "MyApp"}, 
      {"X-RallyIntegrationVendor", "MyCo"}, 
      {"X-RallyIntegrationVersion", "0.1.23"}, 
      {"X-RallyIntegrationOS", "Mac OSX 10.11.6"}
    ]
    expected = [
      {"X-RallyIntegrationName", "MyApp"},
      {"X-RallyIntegrationVendor", "MyCo"},
      {"X-RallyIntegrationVersion", "0.1.23"},
      {"X-RallyIntegrationOS", "Mac OSX 10.11.6"},
      {"X-RallyIntegrationPlatform", "Elixir #{System.version}"},
      {"X-RallyIntegrationLibrary", "RallyRestToolkitForElixir"}
    ]

    assert custom_headers(custom) == expected
  end

  test "normalize_space" do
    original = "Name asc, FormattedID desc"
    expected = "Name asc,FormattedID desc"

    assert normalize_space(original) == expected
  end
end
