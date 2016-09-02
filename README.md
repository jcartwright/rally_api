# RallyApi

RallyApi (rally_api) is a wrapper for Rally's REST Web Services API. Documentation
on the API can be found [here](https://rally1.rallydev.com/slm/doc/webservice/).

## License

Distributed under the MIT License.

## Warranty

The Elixir Toolkit for Rally REST API is available on an as-is basis. It is a
work-in-progress.

### Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `rally_api` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rally_api, "~> 0.1.0"}]
    end
    ```

  2. Ensure `rally_api` is started before your application:

    ```elixir
    def application do
      [applications: [:rally_api]]
    end
    ```

### Usage

Rally's REST Web Services API supports 2 types of authentication.

* Basic authentication
* API Key
