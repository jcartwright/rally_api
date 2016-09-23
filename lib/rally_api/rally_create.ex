defmodule RallyApi.RallyCreate do
  import RallyApi
  alias RallyApi.CreateResult

  def create(client, type, attributes, options \\ []) do
    case path_for(type) do
      {:ok, path} ->
        object = type
          |> wrap_attributes_with_rally_type(attributes)
          |> Poison.encode!

        case post(client, path, object, options) do
          {:ok, response} ->
            result = CreateResult.to_result(response)
            if Enum.empty?(result.errors),
            do:   {:ok, result},
            else: {:error, Enum.at(result.errors, 0)}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  @createable_types [
    allowed_attribute_value: "allowedattributevalue", attachment: "attachment",
    attachment_content: "attachmentcontent", attribute_definition: "attributedefinition",
    build: "build", build_definition: "builddefinition", change: "change", changeset: "changeset",
    conversation_post: "conversationpost", defect: "defect", defect_suite: "defectsuite",
    hierarchical_requirement: "hierarchicalrequirement", iteration: "iteration", milestone: "milestone",
    feature: "portfolioitem/feature", initiative: "portfolioitem/initiative",
    preference: "preference", preliminary_estimate: "preliminaryestimate", project: "project",
    project_permission: "projectpermission", release: "release", scm_repository: "scmrepository", 
    state: "state", story: "hierarchicalrequirement", tag: "tag", task: "task",
    test_case: "testcase", test_case_result: "testcaseresult", test_case_step: "testcasestep",
    test_folder: "testfolder", test_set: "testset", time_entry_item: "timeentryitem",
    time_entry_value: "timeentryvalue", type_definition: "typedefinition", user: "user",
    user_iteration_capacity: "useriterationcapacity", web_link_definition: "weblinkdefinition",
    workspace: "workspace", workspace_permission: "workspacepermission", 
  ]
  def createable_types, do: @createable_types

  def path_for(type) when is_binary(type), do: path_for(String.to_atom(type))

  def path_for(type) when is_atom(type) do
    cond do
      path = createable_types[type] ->
        {:ok, path <> "/create"}
      true ->
        {:error, ":#{type} is not a createable type"}
    end
  end

  def wrap_attributes_with_rally_type(type, %{} = attrs) do
    root = type
      |> Atom.to_string
      |> Macro.camelize

    case attrs do
      %{^root => _} -> attrs
      _ -> %{root => attrs}
    end
  end
end
