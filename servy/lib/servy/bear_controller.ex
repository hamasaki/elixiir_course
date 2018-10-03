defmodule Servy.BearController do
  import Servy.View, only: [render: 3]

  alias Servy.{Bear, Wildthings}

  def index(conv) do
    # items =
    #   Wildthings.list_bears()
    #   |> Enum.filter(&Bear.grizzly?(&1))
    #   |> Enum.sort(&Bear.order_asc_by_name(&1, &2))
    #   |> Enum.map(&bear_item(&1))
    #   |> Enum.join()

    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  # defp bear_item(bear) do
  #   "<li>#{bear.name} - #{bear.type}</li>"
  # end

  def show(conv, %{ "id" => id }) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{ "name" => name, "type" => type }) do
    %{ conv | status: 201, response_body: "Created a #{type} bear named #{name}!" }
  end

  def delete(conv, _params) do
    %{ conv | status: 403, response_body: "Deleting a bear is forbidden!" }
  end
end
