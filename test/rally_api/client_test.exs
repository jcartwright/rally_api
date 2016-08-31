defmodule RallyApi.ClientTest do
  use ExUnit.Case
  import RallyApi.Client

  doctest RallyApi.Client

  test "default endpoint" do
    client = new(%{})
    assert client.endpoint == "https://rally1.rallydev.com/slm/webservice/v2.0/"
  end

  test "custom endpoint" do
    expected = "https://ca.ca.ca/"

    client = new(%{}, "https://ca.ca.ca/")
    assert client.endpoint == expected

    # when trailing / is missing
    client = new(%{}, "https://ca.ca.ca")
    assert client.endpoint == expected
  end
end
