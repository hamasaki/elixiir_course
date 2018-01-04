defmodule Servy.Plugins do
  @moduledoc "Plugins"

  require Logger
  alias Servy.Conv

  @rewrite_path_regex ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}

  def rewrite_path(%Conv{ path: path } = conv) do
    @rewrite_path_regex
    |> Regex.named_captures(path)
    |> rewrite_path_captures(conv)
  end

  defp rewrite_path_captures(%{ "thing" => thing, "id" => id }, %Conv{} = conv) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  defp rewrite_path_captures(nil, conv), do: conv

  # def rewrite_path(%{ path: "/wildlife" } = conv) do
  #   %{ conv | path: "/wildthings" }
  # end

  # def rewrite_path(%{ path: "/bears?id=" <> id } = conv) do
  #   %{ conv | path: "/bears/#{id}" }
  # end

  # def rewrite_path(conv), do: conv

  # "conv" means conversation map.
  def log(%Conv{} = conv) do
    conv
    |> inspect
    |> Logger.info

    conv
  end

  def track(%Conv{ status: 404, path: path } = conv) do
    Logger.warn "Warning: #{path} is on the loose!"
    conv
  end

  def track(%Conv{} = conv), do: conv
end
