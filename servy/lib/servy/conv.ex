defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            params: %{},
            response_body: "",
            status: nil

  @status_reasons %{
    200 => "OK",
    201 => "Created",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    500 => "Internal Server Error"
  }

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(status) do
    @status_reasons[status]
  end
end
