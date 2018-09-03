defmodule Summing do
  def sum([head | tail]), do: sum([head | tail], 0)

  defp sum([head | tail], total), do: sum(tail, head + total)

  defp sum([], total), do: total
end

IO.puts Summing.sum([1, 2, 3, 4, 5])

# Write a triple function that takes a list of numbers and returns a new list consisting of each of
# the original numbers multiplied by 3. For example, if you call triple with a list of numbers 1 to 5 like so
# IO.inspect Recurse.triple([1, 2, 3, 4, 5])
#
# then the result should be:
# [3, 6, 9, 12, 15]

defmodule Recurse do
  def triple([head | tail]), do: [head * 3 | triple(tail)]

  def triple([]), do: []
end

IO.inspect Recurse.triple([1, 2, 3, 4, 5])
