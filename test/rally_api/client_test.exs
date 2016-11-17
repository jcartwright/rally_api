defmodule RallyApi.ClientTest do
  use ExUnit.Case
  import RallyApi.Client

  doctest RallyApi.Client

  test "default endpoint" do
    client = new(%{})
    assert client.endpoint == "https://rally1.rallydev.com/slm/webservice/v2.0/"
  end

  test "endpoint" do
    client = new(%{endpoint: "https://my/custom/endpoint"})
    assert client.endpoint == "https://my/custom/endpoint"
  end

  test "auth token" do
    client = new(%{auth: "token"})
    assert client.auth == "token"
  end

  test "auth map username/password" do
    client = new(%{auth: %{user: "user@email.com", password: "P@ssw0rd!"}})
    assert client.auth == %{user: "user@email.com", password: "P@ssw0rd!"}
  end

  test "workspace" do
    client = new(%{workspace: "https://path/to/workspace/ref"})
    assert client.workspace == "https://path/to/workspace/ref"
  end
end
