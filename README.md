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
    {:freebsd, "~> 0.4.1", runtime: false}
  ]
end
```

Add a `freebsd` key to `mix.exs` project config.

```elixir
  def project do
    [
      # ExFreeBSD requires these standard keys:
      app: :freebsd,
      version: "0.4.1",
      description: description(),
      homepage_url: "https://github.com/patmaddox/ex_freebsd",
      # and adds this one:
      freebsd: freebsd()
    ]
  end

  defp freebsd do
    [
      maintainer: "pat@patmaddox.com",
      description: description() # can be a multi-line string instead
    ]
  end
```

## Usage

Build a release as usual: `env MIX_ENV=prod mix release --overwrite`

`env MIX_ENV=prod mix freebsd.pkg` will produce a FreeBSD .pkg file which you can then install as usual.

`ExFreeBSD` produces `/usr/local/etc/rc.d/<appname>` which provides the following commands:

- `start`
- `stop`
- `restart`
- `status`
- `remote`

Run them using [`service(8)`](https://www.freebsd.org/cgi/man.cgi?service(8)).

After installing the package, you can define application-specific environment variables in `/usr/local/etc/<appname>.env`:

```
DATABASE_URL=ecto://user:password@host/db
AWS_ACCESS_KEY_ID=abc123def456
```

Logs and crash dumps default to `/var/run/<appname>`.

## Roadmap

- list dependencies
- auto-name package w/ CI suffix: `<app>-ci-<branch>-<version>p<timestamp>`
- MANIFEST conflict for `<app> <app>-ci-*`
- run as non-privileged user
- document epmd usage (run it as a service, not automatically by package)
- build package as part of a release