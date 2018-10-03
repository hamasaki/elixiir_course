defmodule Servy.View do
  @template_path Path.expand("templates", File.cwd!)

  def render(conv, template, bindings \\ []) do
    content =
      @template_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{ conv | status: 200, response_body: content }
  end
end
