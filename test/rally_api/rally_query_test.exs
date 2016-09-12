defmodule RallyApi.RallyQueryTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  
  import RallyApi.RallyQuery
  
  alias RallyApi.{Client, QueryResult}

  @client RallyApi.Client.new(%{zsessionid: "_lopoalp1TxyqCH3p7s1FWco2ROI90uxpii7ubJYH8"})
  
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
    assert error == "invalid is not a valid query type"
  end

  @tag :wip
  test "find/3 with invalid query" do
    use_cassette "rally_query#find_invalid", match_requests_on: [:query] do
      type = :story
      query = "(InvalidField = 999)"

      {:error, error} = find(@client, type, query)
      assert error =~ ~r/^Could not parse/
    end
  end


end
