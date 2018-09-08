add = &(&1 + &2)
add.(5, 5)

repeat = &String.duplicate/2
repeat.("123pim", 3)


defmodule Recurse do
  def my_map([head | tail], function) do
    [function.(head) | my_map(tail, function)]
  end

  def my_map([], _function), do: []
end

nums = [1, 2, 3, 4, 5]

Recurse.my_map(nums, &(&1 * 2))
Recurse.my_map(nums, &(&1 * 4))
Recurse.my_map(nums, &(&1 * 5))
