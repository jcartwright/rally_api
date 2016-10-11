ExUnit.configure(exclude: [pending: true])
ExUnit.start()
ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes")

defmodule RallyApi.TestHelper do
  def simple_defect_attributes do
    %{"Defect" =>
      %{"Name" => "Simple Defect for Update",
        "Priority" => "Normal",
        "c_CreationTeamName" => "Creation Team not assigned yet",
        "Project" => %{"_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/project/55700974877"}
      }
    }
  end
end
