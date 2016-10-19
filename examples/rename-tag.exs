# This is an example of renaming a tag in Rally
# Setup:
# - Make sure you have a config/dec/exs file with a valid API key or user/password
#
# $ mix run examples/rename-tag.exs
defmodule RenameTag do
  alias RallyApi.{Client, CreateResult, QueryResult}

  @client Client.new(%{zsessionid: Application.get_env(:rally_api, :api_key)})
  @project_ref "https://rally1.rallydev.com/slm/webservice/v2.0/project/55699003530"

  def main do
    old_tag_name = "rename-me"
    # Create a tag that will be added to some stories
    {:ok, old_tag_ref} = create_tag(old_tag_name)

    # Create a few stories and tag them
    create_stories_with_tag(old_tag_ref)

    # Query for stories by tag & display them
    IO.puts "Stories tagged with #{old_tag_name}..."
    stories = find_stories_with_tag(old_tag_name)
    show_stories(stories)

    # Create another tag, and swap the new tag for the old one
    new_tag_name = "renamed"
    {:ok, new_tag_ref} = create_tag(new_tag_name)
    
    stories
      |> Enum.each(fn(story) ->
        # Add the new tag to the Story.Tags collection
        RallyApi.RallyCollection.add(@client, get_ref(story), :tags, [%{"_ref" => new_tag_ref}])

        # Remove the old tag from the Story.Tags collection
        RallyApi.RallyCollection.remove(@client, get_ref(story), :tags, [%{"_ref" => old_tag_ref}])
      end)

    IO.puts "Stories tagged with #{new_tag_name}..."
    stories = find_stories_with_tag(new_tag_name)
    show_stories(stories)

    delete_stories(stories)
    archive_tags([old_tag_ref, new_tag_ref])
  end

  defp create_tag(name) do
    {:ok, %CreateResult{object: tag}} = RallyApi.RallyCreate.create(@client, :tag, %{"Name" => name})
    {:ok, get_ref(tag)}
  end

  defp archive_tags(tag_refs) do
    # Tags cannot be deleted via the API, only archived
    IO.puts "** TODO: Implement archive_tags/1 function **"
    # tag_refs
    # |> Enum.each(fn(tag_ref) ->
      # TODO: find/read tags
    # RallyApi.RallyDelete.delete(@client, :tag, tag_id)
    # end)
  end

  defp create_stories_with_tag(tag_ref) do
    for x <- (1..3) do
      attrs = %{
        "Name" => "Test Story #{x}",
        "c_CreationTeamName" => "Creation Team not assigned yet",
        "Project" => %{"_ref" => @project_ref}
      }

      case RallyApi.RallyCreate.create(@client, :story, attrs) do
        {:ok, %CreateResult{object: story}} ->
          story
          |> get_ref
          |> add_tag_to_story(tag_ref)
        {:error, reason} ->
          IO.puts reason
      end
    end
  end

  defp add_tag_to_story(story_ref, tag_ref) do
    RallyApi.RallyCollection.add(@client, story_ref, :tags, [%{"_ref" => tag_ref}])
  end

  defp find_stories_with_tag(tag_name) do
    query = "(Tags.Name = \"#{tag_name}\")"
    fetch = "FormattedID,ObjectID,Name,Tags"
    options = [project: @project_ref, order: "FormattedID"]

    case RallyApi.RallyQuery.find(@client, :story, query, fetch, options) do
      {:ok, %QueryResult{results: stories}} -> stories
    end
  end

  defp delete_stories(stories) do
    stories
    |> Enum.each(fn(story) ->
      case RallyApi.RallyDelete.delete(@client, :story, story["ObjectID"]) do
        {:ok, result} ->
          IO.puts "Deleted Story #{story["FormattedID"]}"
        {:error, reason} ->
          IO.puts reason
      end
    end)
  end

  defp get_ref(object) when is_map(object) do
    object |> Map.fetch!("_ref")
  end

  defp show_stories(stories) do
    table_width = 54
    col_widths = [id: 6, name: 20, tags: 18]
    row_sep = String.duplicate("-", table_width)
    table_sep = String.duplicate("=", table_width) <> "\n"

    IO.puts row_sep
    IO.puts "| #{String.pad_trailing("ID", col_widths[:id])} | #{String.pad_trailing("Name", col_widths[:name])} | #{String.pad_trailing("Tags", col_widths[:tags])} |"
    
    Enum.each(stories, fn(story) ->
      id = String.pad_trailing(story["FormattedID"], col_widths[:id])
      name = String.pad_trailing(story["Name"], col_widths[:name])
      tags = Enum.map(story["Tags"]["_tagsNameArray"], &(&1["Name"]))
        |> Enum.join(", ")
        |> String.pad_trailing(col_widths[:tags])

      IO.puts row_sep
      IO.puts "| #{id} | #{name} | #{tags} |" 
    end)
    
    IO.puts table_sep
  end
end

# Here's where we run the example...
IO.puts "Example: Rename a Tag in Rally"
IO.puts "------------------------------"

RenameTag.main

IO.puts "DONE"
IO.puts "------------------------------"
