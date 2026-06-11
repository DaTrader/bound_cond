# BoundCond

`bound_cond/1` — a `cond` that lets you thread **interim variables** through its
clauses.

Plain `cond` runs the first truthy clause's body, but each clause is isolated: a
value you compute while testing one condition can't be reused by the next. `with`
*can* thread state, but it models a single happy path with fallbacks — not several
branches of equal priority. `bound_cond` fills that gap.

```elixir
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
```

Clauses are tried top to bottom, exactly like `cond`. A `:bind ->` clause never
*matches* — its body runs only when execution falls through to it, and the
variables it binds are in scope for every clause below it. You can use as many
`:bind ->` steps as you like, and each sees the ones before it. As with `cond`,
nothing bound inside leaks out of the `bound_cond`. If no clause matches,
`bound_cond` raises `CondClauseError`, just like `cond`.

It expands to nested `if`/`else` wrapped in a `case` (used only to scope the
bindings), so there is effectively no runtime overhead — the macro is purely a
way to keep the source flat and declarative instead of hand-rolling nested `if`s.

## Installation

Add `bound_cond` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    { :bound_cond, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get`. The API reference lives on
[HexDocs](https://hexdocs.pm/bound_cond).

## How it works

Once a `do` block contains any `->`, Elixir parses it in *stab-clause mode*, where
every non-arrow line is folded into the preceding clause's body. So free-floating
bindings between clauses aren't possible; instead, a binding step is written as a
clause with the reserved head `:bind`, and the macro splices that body into the
fall-through path of the `if`/`else` chain it builds.

## Test

```sh
mix test
```

## License

Released under the MIT License — see [LICENSE](LICENSE).

Copyright (c) 2026 DaTrader.
