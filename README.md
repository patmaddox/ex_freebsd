# ExFreeBSD

Documentation: <https://hexdocs.pm/freebsd>

## Installation

Add `freebsd` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:freebsd, "~> 0.2.0"}
  ]
end
```

## Usage

1. `mix freebsd.gen.pkg`
2. Add `freebsd:` and `package:` keys to mix project config (see `mix.exs` for an example).
3. `mix freebsd.pkg`

`mix freebsd.pkg` will generate a FreeBSD .pkg file under freebsd/ which you can then install as usual.

The generated files will automatically produce:

- `/usr/local/bin/<app_name>`
- `/usr/local/etc/rc.d/<app_name>`

You may modify the generated files however you like, and rebuild the package.
