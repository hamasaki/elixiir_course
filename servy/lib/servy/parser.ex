defmodule Servy.Parser do
  @moduledoc "Parser"

  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _http_version] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
       path: path,
       params: params,
       headers: headers
     }
  end

  defp parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn (line, acc) ->
      [key, value] = String.split(line, ": ")
      Map.put(acc, key, value)
    end)
  end

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  defp parse_params(_content_type, _params_string), do: %{}
end
