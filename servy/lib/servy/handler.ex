defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  alias Servy.Conv

  # @pages_path Path.expand("../../pages", __DIR__)
  @pages_path Path.expand("pages", File.cwd!)

  import Servy.FileHandler, only: [handle_file: 2]
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, response_body: "Bears, Lions, Tigers, Foxs" }
  end

  defp route(%Conv{ method: "GET", path: "/bears" } = conv) do
    %{ conv | status: 200, response_body: "Teddy, Smokey, Paddington" }
  end

  defp route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  defp route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, response_body: "Bear #{id}" }
  end

  defp route(%Conv{ method: "DELETE", path:  "/bears/" <> _id } = conv) do
    %{ conv | status: 403, response_body: "Deleting a bear is forbidden!" }
  end

  # name=Baloo&type=Brown
  defp route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{ conv | status: 201, response_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}!" }
  end

  defp route(%Conv{ method: "GET", path: "/about" } = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  defp route(%Conv{ method: "GET", path: "/pages/" <> file } = conv) do
    @pages_path
    |> Path.join("#{file}.html")
    |> File.read
    |> handle_file(conv)
  end

  # defp route(%{ method: "GET", path:  "/about" } = conv) do
  #   file =
  #     Path.expand("../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{ conv | status: 200, response_body: content }

  #     {:error, :enoent} ->
  #       %{ conv | status: 404, response_body: "File not found!" }

  #     {:error, reason} ->
  #       %{ conv | status: 500, response_body: "File error: #{reason}" }
  #   end
  # end

  defp route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, response_body: "No #{path} here!" }
  end

  defp format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.response_body)}

    #{conv.response_body}
    """
  end
end
