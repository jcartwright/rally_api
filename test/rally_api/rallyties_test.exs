defmodule RallyApi.RallytiesTest do
  use ExUnit.Case
  import RallyApi.Rallyties

  doctest RallyApi.Rallyties

  test "get_ref/1" do
    expected = "https://path/to/object/_object_id_"

    object = %{"_ref" => expected}
    assert get_ref(object) == expected

    object = %{"Defect" => %{"_ref" => expected}}
    assert get_ref(object) == expected
  end
end
