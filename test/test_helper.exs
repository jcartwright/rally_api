ExUnit.configure(exclude: [pending: true])
ExUnit.start()
ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes")

defmodule RallyApi.TestHelper do
  @default_project Application.get_env(:rally_api, :default_project)
  def simple_defect_attributes do
    %{"Defect" =>
      %{"Name" => "Simple Defect for Update",
        "Priority" => "Normal",
        "Project" => %{"_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/project/76001020472"}
      }
    }
  end
end
