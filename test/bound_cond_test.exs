defmodule BoundCondTest do
  use ExUnit.Case
  import BoundCond
  doctest BoundCond

  # Helpers used by the running example from the README/moduledoc.
  defp in_range?( x, y), do: x >= 0 and x <= y
  defp get_last( x), do: x * 10
  defp get_pos( y), do: y + 1

  defp classify( x, y) do
    bound_cond do
      in_range?( x, y) ->
        :in_range

      :bind ->
        last = get_last( x)
        pos = get_pos( y)

        pos > last ->
          { :past_last, last: last, pos: pos}

        true ->
          { :default, pos}
    end
  end

  test "a clause that matches before the bindings wins" do
    assert classify( 2, 5) == :in_range
  end

  test "interim bindings are visible to a later condition and body" do
    assert classify( -1, 5) == { :past_last, last: -10, pos: 6}
  end

  test "falls through to the true clause, still seeing the bindings" do
    assert classify( 100, 5) == { :default, 6}
  end

  test "raises CondClauseError when nothing matches" do
    assert_raise CondClauseError, fn ->
      bound_cond do
        1 > 2 ->
          :a

        :bind ->
          _x = 3

          2 > 3 ->
            :b
      end
    end
  end

  test ":bind may come first, as pure setup" do
    result =
      bound_cond do
        :bind ->
          base = 10

          base > 5 ->
            { :ok, base}

          true ->
            :no
      end

    assert result == {:ok, 10}
  end

  test "multiple :bind groups accumulate, each seeing the previous" do
    n = 0

    result =
      bound_cond do
        n > 0 ->
          :never

        :bind ->
          a = 1

          n > 1 ->
            :nope

          :bind ->
            b = a + 1

            true ->
              { a, b}
      end

    assert result == {1, 2}
  end

  test "a :bind reached via fall-through is contained (does not leak out)" do
    flag = false

    _ =
      bound_cond do
        flag ->
          :early

        :bind ->
          contained = 99

          true ->
            contained
      end

    refute Macro.Env.has_var?( __ENV__, { :contained, nil})
  end

  test "an unconditional :bind does not leak or clobber an outer variable" do
    x = 100

    result =
      bound_cond do
        :bind ->
          x = 1

          x > 5 ->
            :big

          true ->
            :small
      end

    assert result == :small
    assert x == 100
  end
end
