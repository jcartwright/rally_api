defmodule RallyApi.Rallyties do
  @moduledoc """
  This module contains shared functions for making things Rallyfied
  """

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

  @queryable_types [
    artifact: "artifact", artifact_notification: "artifactnotification", attachment: "attachment",
    blocker: "blocker", build: "build", build_definition: "builddefinition",
    change: "change", changeset: "changeset", conversation_post: "conversationpost",
    defect: "defect", defect_suite: "defectsuite", hierarchical_requirement: "hierarchicalrequirement",
    iteration: "iteration", iteration_cumulative_flow_data: "iterationcumulativeflowdata",
    milestone: "milestone", portfolio_item: "portfolioitem", feature: "portfolioitem/feature",
    initiative: "portfolioitem/initiative", preference: "preference",
    preliminary_estimate: "preliminaryestimate", project: "project", project_permission: "projectpermission",
    recycle_bin_entry: "recyclebinentry", release: "release",
    release_cumulative_flow_data: "releasecumulativeflowdata", requirement: "requirement", revision: "revision",
    schedulable_artifact: "schedulableartifact", scm_repository: "scmrepository", state: "state",
    story: "hierarchicalrequirement", subscription: "subscription", tag: "tag",
    task: "task", test_case: "testcase", test_case_result: "testcaseresult",
    test_case_step: "testcasestep", test_folder: "testfolder", test_set: "testset",
    time_entry_item: "timeentryitem", time_entry_value: "timeentryvalue", type_definition: "typedefinition",
    user: "user", user_iteration_capacity: "useriterationcapacity", user_permission: "userpermission",
    user_profile: "userprofile", workspace: "workspace", workspace_configuration: "workspaceconfiguration",
    workspace_permission: "workspacepermission", 
  ]
  def queryable_types, do: @queryable_types


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
