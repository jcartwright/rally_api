defmodule RallyApi.RallyQuery do
  import RallyApi

  def find(client, type, query, fetch, options \\ []) do
    case path_for(type) do
      {:ok, path} ->
        client
        |> get(path, query, fetch, options)
      {:error, reason} -> {:error, reason}
    end
  end

  def find(client, type, query), do: find(client, type, query, "")

  def find(client, type), do: find(client, type, "")

  # TODO: Maybe there is a better way to define this queryable type to path data?
  @queryable_types [
    artifact: "artifact", artifact_notification: "artifactnotification", attachment: "attachment",
    blocker: "blocker", build: "build", build_definition: "builddefinition",
    change: "change", changeset: "changeset", conversation_post: "conversationpost",
    defect: "defect", defect_suite: "defectsuite", hierarchical_requirement: "hierarchicalrequirement",
    iteration: "iteration", iteration_cumulative_flow_data: "iterationcumulativeflowdata",
    milestone: "milestone",
    portfolio_item: "portfolioitem", feature: "portfolioitem/feature", initiative: "portfolioitem/initiative",
    preference: "preference", preliminary_estimate: "preliminaryestimate", project: "project",
    project_permission: "projectpermission", recycle_bin_entry: "recyclebinentry", release: "release",
    release_cumulative_flow_data: "releasecumulativeflowdata", requirement: "requirement", revision: "revision",
    schedulable_artifact: "schedulableartifact", scm_repository: "scmrepository", state: "state",
    story: "hierarchicalrequirement", subscription: "subscription", tag: "tag",
    task: "task", test_case: "testcase", test_case_result: "testcaseresult",
    test_case_step: "testcasestep", test_folder: "testfolder", test_set: "testset",
    time_entry_item: "timeentryitem", time_entry_value: "timeentryvalue", type_definition: "typedefinition",
    user: "user", user_iteration_capacity: "useriterationcapacity", user_permission: "userpermission",
    user_profile: "userprofile", workspace_configuration: "workspaceconfiguration",
    workspace_permission: "workspacepermission", workspace: "workspace",
  ]
  def queryable_types, do: @queryable_types

  def path_for(type) when is_binary(type), do: path_for(String.to_atom(type))

  def path_for(type) when is_atom(type) do
    cond do
      path = queryable_types[type] ->
        {:ok, path}
      true ->
        {:error, ":#{type} is not a valid query type"}
    end
  end

end
