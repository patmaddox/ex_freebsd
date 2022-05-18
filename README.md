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

1. `mix freebsd.gen.pkg`
2. Edit `freebsd/*.eex` as desired (particularly desc in `freebsd/MANIFEST.eex`
3. Add a `freebsd` key to `mix.exs` project config.

```elixir
  def project do
    [
      # ExFreeBSD requires these standard keys:
      app: :freebsd,
      version: "0.2.0",
      description: description(),
      homepage_url: "https://github.com/patmaddox/ex_freebsd",
      # and adds this one:
      freebsd: freebsd()
    ]
  end

  defp freebsd do
    [
      maintainer: "pat@patmaddox.com",
      pkg_prefix: "/usr/local"
    ]
  end
```

## Usage

`mix freebsd.pkg` will produce a FreeBSD .pkg file under freebsd/ which you can then install as usual.
