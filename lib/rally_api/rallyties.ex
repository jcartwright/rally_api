defmodule RallyApi.Rallyties do
  @moduledoc """
  This module contains shared functions for making things Rallyfied
  """

  @doc """
  Rally expects the body JSON to have the Object Type as the root attibute.
  This function takes a `Map` and prepends the Object Type if it is not
  already the root attribute.

  ## Examples:

    iex> RallyApi.Rallyties.wrap_attributes_with_rally_type(:defect, %{"Name" => "A Defect"})
    %{"Defect" => %{"Name" => "A Defect"}}

    iex> RallyApi.Rallyties.wrap_attributes_with_rally_type(:defect, %{"Defect" => %{"Name" => "A Defect"}})
    %{"Defect" => %{"Name" => "A Defect"}}

    iex> RallyApi.Rallyties.wrap_attributes_with_rally_type(:conversation_post, %{"Artifact" => "path/to/artifact"})
    %{"ConversationPost" => %{"Artifact" => "path/to/artifact"}}
  """
  def wrap_attributes_with_rally_type(type, attrs) when is_map(attrs) do
    root = type
      |> Atom.to_string
      |> Macro.camelize

    case attrs do
      %{^root => _} -> attrs
      _ -> %{root => attrs}
    end
  end
end
