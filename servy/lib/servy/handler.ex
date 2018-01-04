defmodule Servy.Handler do
  require Logger

  @status_reasons %{
    200 => "OK",
    201 => "Created",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    500 => "Internal Server Error"
  }

  @rewrite_path_regex ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{ method: method,
       path: path,
       response_body: "",
       status: nil
     }
  end

  defp rewrite_path(%{ path: path } = conv) do
    @rewrite_path_regex
    |> Regex.named_captures(path)
    |> rewrite_path_captures(conv)
  end

  defp rewrite_path_captures(%{ "thing" => thing, "id" => id }, conv) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  defp rewrite_path_captures(nil, conv), do: conv

  # defp rewrite_path(%{ path: "/wildlife" } = conv) do
  #   %{ conv | path: "/wildthings" }
  # end

  # defp rewrite_path(%{ path: "/bears?id=" <> id } = conv) do
  #   %{ conv | path: "/bears/#{id}" }
  # end

  # defp rewrite_path(conv), do: conv

  # "conv" means conversation map.
  defp log(conv) do
    conv
    |> inspect
    |> Logger.info

    conv
  end

  defp route(%{ method: "GET", path:  "/wildthings" } = conv) do
    %{ conv | status: 200, response_body: "Bears, Lions, Tigers, Foxs" }
  end

  defp route(%{ method: "GET", path:  "/bears" } = conv) do
    %{ conv | status: 200, response_body: "Teddy, Smokey, Paddington" }
  end

  defp route(%{ method: "GET", path:  "/bears/" <> id } = conv) do
    %{ conv | status: 200, response_body: "Bear #{id}" }
  end

  defp route(%{ method: "DELETE", path:  "/bears/" <> _id } = conv) do
    %{ conv | status: 403, response_body: "Deleting a bear is forbidden!" }
  end

  defp route(%{ method: "GET", path:  "/about" } = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
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

  defp route(%{ path: path } = conv) do
    %{ conv | status: 404, response_body: "No #{path} here!" }
  end

  defp handle_file({:ok, content}, conv) do
    %{ conv | status: 200, response_body: content }
  end

  defp handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, response_body: "File not found!" }
  end

  defp handle_file({:error, reason}, conv) do
    %{ conv | status: 500, response_body: "File error: #{reason}" }
  end

  defp track(%{ status: 404, path: path } = conv) do
    Logger.warn "Warning: #{path} is on the loose!"
    conv
  end

  defp track(conv), do: conv

  defp format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.response_body)}

    #{conv.response_body}
    """
  end

  defp status_reason(status) do
    @status_reasons[status]
  end
end
