defmodule RallyApi.RallyQuery do
  import RallyApi
  alias RallyApi.{Client, QueryResult}

  def find(client, type, query, fetch) do
    case path_for(type) do
      {:ok, path} ->
        client
        |> get(path, query, fetch)
      {:error, reason} -> {:error, reason}
    end
  end

  def find(client, type, query), do: find(client, type, query, "")

  # TODO: Maybe there is a better way to define this queryable type to path data?
  @queryable_types [
    artifact: "artifact", artifactnotification: "artifactnotification", attachment: "attachment",
    blocker: "blocker", build: "build", builddefinition: "builddefinition",
    change: "change", changeset: "changeset", conversationpost: "conversationpost",
    defect: "defect", defectsuite: "defectsuite", hierarchicalrequirement: "hierarchicalrequirement",
    iteration: "iteration", iterationcumulativeflowdata: "iterationcumulativeflowdata", milestone: "milestone",
    portfolioitem: "portfolioitem", feature: "portfolioitem/feature", initiative: "portfolioitem/initiative",
    preference: "preference", preliminaryestimate: "preliminaryestimate", project: "project",
    projectpermission: "projectpermission", recyclebinentry: "recyclebinentry", release: "release",
    releasecumulativeflowdata: "releasecumulativeflowdata", requirement: "requirement", revision: "revision",
    schedulableartifact: "schedulableartifact", scmrepository: "scmrepository", state: "state",
    story: "hierarchicalrequirement", subscription: "subscription", tag: "tag",
    task: "task", testcase: "testcase", testcaseresult: "testcaseresult",
    testcasestep: "testcasestep", testfolder: "testfolder", testset: "testset",
    timeentryitem: "timeentryitem", timeentryvalue: "timeentryvalue", typedefinition: "typedefinition",
    user: "user", useriterationcapacity: "useriterationcapacity", userpermission: "userpermission",
    userprofile: "userprofile", workspaceconfiguration: "workspaceconfiguration",
    workspacepermission: "workspacepermission", workspace: "workspace",
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
