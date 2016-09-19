defmodule RallyApi.RallyQueryTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  
  import RallyApi.RallyQuery
  
  alias RallyApi.{Client, QueryResult}

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
    
  setup do
    ExVCR.Config.filter_request_headers("ZSESSIONID")
    :ok
  end
  
  test "find/3" do
    use_cassette "rally_query#find", match_requests_on: [:query] do
      type = :story
      query = "((Owner.LastName = Cartwright) AND (ScheduleState = Accepted))"

      {:ok,
        %QueryResult{
          total_result_count: count,
          results: results,
        }
      } = find(@client, type, query)

      assert count > 0
      refute Enum.empty?(results)
    end
  end

  test "find/3 with invalid type" do
    type = :invalid
    query = "(Owner.LastName = Cartwright)"

    {:error, error} = find(@client, type, query)
    assert error == ":invalid is not a valid query type"
  end

  test "find/3 with invalid query" do
    use_cassette "rally_query#find_invalid", match_requests_on: [:query] do
      type = :story
      query = "(InvalidField = 999)"

      {:error, error} = find(@client, type, query)
      assert error =~ ~r/^Could not parse/
    end
  end

  test "find/4" do
    use_cassette "rally_query#find_with_fetch" do
      type = :story
      query = "(Owner.LastName = Cartwright)"
      fetch = "FormattedID,Name"

      {:ok, %QueryResult{results: stories}} = find(@client, type, query, fetch)
      refute Enum.empty?(stories)
      Enum.each(stories, fn(r) -> 
        assert Map.has_key?(r, "FormattedID") 
        assert Map.has_key?(r, "Name")
      end)
    end
  end
  
  test "find/4 ignores invalid fetch" do
    use_cassette "rally_query#find_with_invalid_fetch" do
      type = :story
      query = "(Owner.LastName = Cartwright)"
      fetch = "FormattedID,Invalid"

      {_, %QueryResult{results: stories}} = find(@client, type, query, fetch)
      Enum.each(stories, fn(r) ->
        assert Map.has_key?(r, "FormattedID")
        refute Map.has_key?(r, "Invalid")
      end)
    end
  end

  test "path_for/1 with queryable types" do
    Enum.each(queryable_types, fn(query_type) ->
      assert {:ok, _path} = path_for(elem(query_type, 0))
    end)
  end

  test "path_for/1 with unknown type" do
    assert {:error, ":foobar is not a valid query type"} = path_for(:foobar)
    assert {:error, ":foobar is not a valid query type"} = path_for("foobar")
  end
end
