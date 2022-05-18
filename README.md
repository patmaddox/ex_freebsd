# ExFreeBSD

Helping [Elixir mix releases](https://hexdocs.pm/mix/Mix.Tasks.Release.html) become [FreeBSD packages](https://docs.freebsd.org/en/books/handbook/ports/), since 2022.

Documentation: <https://hexdocs.pm/freebsd>

## Installation

You DO need `elixir` to build your release and package. You can install it with `pkg install elixir`.

You DO NOT need `elixir` to run your app, assuming your mix release configures `include_erts: true` (which is the default).

Add `freebsd` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:freebsd, "~> 0.3.2", runtime: false}
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
      version: "0.3.2",
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

`env MIX_ENV=prod mix freebsd.pkg` will produce a FreeBSD .pkg file under freebsd/ which you can then install as usual.

`freebsd/rc.eex` produces `/usr/local/etc/rc.d/<appname>` which provides the following commands:

- `start`
- `stop`
- `restart`
- `status`
- `pid`
- `remote`

Run them using [`service(8)`](https://www.freebsd.org/cgi/man.cgi?service(8)).

## Roadmap

- generate / copy `rc.conf`
- list dependencies
- auto-name package w/ CI suffix: `<app>-ci-<branch>-<version>p<timestamp>`
- MANIFEST conflict for `<app> <app>-ci-*`
