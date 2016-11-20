defmodule RallyApi.SecurityTokenTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  
  import RallyApi
  alias RallyApi.{Client}

  @client Client.new(
    %{auth: %{user: Application.get_env(:rally_api, :user), password: Application.get_env(:rally_api, :password)}}
  )

  setup do
    ExVCR.Config.filter_request_headers("Authorization")
    :ok
  end

  test "get security token with valid creds" do
    use_cassette "security_token#with_valid_creds" do
      {:ok, response} = get_security_token(@client)
      assert response["OperationResponse"]["SecurityToken"] != ""

      token = get_security_token!(@client)
      assert String.length(token) > 0
    end
  end

  test "get security token with invalid creds" do
    client = Client.new(%{user: "unknown@example.com", password: "thisisaf@kepa$$"})

    use_cassette "security_token#with_invalid_creds" do
      {:error, reason} = get_security_token(client)
      assert reason =~ ~r/^Error 401/

      assert_raise RuntimeError, ~r/^Error 401/, fn ->
        get_security_token!(client)
      end
    end
  end
end
