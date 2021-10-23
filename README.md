# Venezia

An elixir app displaying schedule and results for any Serie A team.

### Example

```elixir
{:ok, pid} = LegaSerieA.start_link([])
LegaSerieA.get_schedule(pid, "venezia")
```