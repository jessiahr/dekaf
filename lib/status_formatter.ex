defmodule Dekaf.StatusFormatter do
  def format(message), do: to_map(message)

  def to_map([{}]), do: []

  def to_map(message) when is_list(message) do
    message
    |> Enum.map(&to_map(&1))
    |> Enum.into(%{})
  end

  def to_map({key, value}) do
    {key, to_map(value)}
  end

  def to_map(message)
      when is_binary(message) or is_number(message) or is_boolean(message),
      do: message
end
