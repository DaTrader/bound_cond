defmodule BoundCond do
  @moduledoc """
  `bound_cond/1` — a `cond` whose clauses can thread interim variables.

  Plain `cond` runs the first truthy clause's body, but each clause is isolated:
  a value computed while testing one condition can't be reused by the next.
  `with` *can* thread state, but it models a single happy path with fallbacks —
  not several branches of equal priority. `bound_cond/1` fills that gap.

  Clauses are tried top to bottom, exactly like `cond`. To introduce variables
  for the clauses that follow, add a `:bind ->` step:

      import BoundCond

      bound_cond do
        in_range?( x, y) ->
          n

        :bind ->
          last = get_last( x)
          pos = get_pos( y)

        pos > last ->
          last

        true ->
          pos
      end

  A `:bind ->` clause never "matches": its body runs only when execution falls
  through to it, and the variables it binds stay in scope for every clause below
  it — but, like `cond`, nothing bound inside a `bound_cond` leaks out of it
  (not even an unconditional `:bind`). If no clause matches, a `CondClauseError`
  is raised, just like `cond`.

  It expands to nested `if`/`else` wrapped in a `case` (used only to open a
  scope, so the bindings can't leak), so there is effectively no runtime
  overhead.
  """

  @doc """
  A `cond` whose clauses can share interim variables.

  Use one or more `:bind -> ...` steps to bind variables for the clauses that
  follow them.

  ## Examples

      iex> import BoundCond
      BoundCond
      iex> x = 7
      7
      iex> bound_cond do
      ...>   x < 0 ->
      ...>    :negative
      ...>
      ...>   :bind ->
      ...>     doubled = x * 2
      ...>
      ...>   doubled > 10 ->
      ...>     { :big, doubled}
      ...>
      ...>   true ->
      ...>     { :small, doubled}
      ...> end
      {:big, 14}
  """
  defmacro bound_cond( do: clauses) do
    body =
      clauses
      |> List.wrap()
      |> build()

    # The `case` is there to open a scope: keeps everything bound inside.
    quote do
      case nil do
        _ -> unquote( body)
      end
    end
  end

  # `:bind ->` — run the body for its bindings, then continue. The body is
  # spliced into the surrounding block (a bare `__block__` is not a new scope),
  # so anything it binds is visible to every clause built into `rest`.
  defp build([{ :->, _, [[ :bind], body]} | rest]) do
    quote do
      unquote( body)
      unquote( build( rest))
    end
  end

  # `condition -> body` — every clause compiles to one of these.
  defp build([{ :->, _, [[ condition], body]} | rest]) do
    quote do
      if unquote( condition) do
        unquote( body)
      else
        unquote( build( rest))
      end
    end
  end

  # No clause matched — mirror `cond`.
  defp build( []) do
    quote do
      raise CondClauseError
    end
  end

  # A clause head that isn't a single condition (or `:bind`).
  defp build([{ :->, _, [ head, _body]} | _rest]) do
    raise ArgumentError,
          "bound_cond: each clause needs exactly one condition or `:bind`, got: " <>
            Macro.to_string({ :->, [], [ head, :...]})
  end
end
