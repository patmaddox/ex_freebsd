# ExFreeBSD

Helping [Elixir mix releases](https://hexdocs.pm/mix/Mix.Tasks.Release.html) become [FreeBSD packages](https://docs.freebsd.org/en/books/handbook/ports/), since 2022.

Documentation: <https://hexdocs.pm/freebsd>

## Installation

You DO need `elixir` to build your release and package.
You can install it with `pkg install elixir`.
(See **Choosing an OTP Version** below).

You DO NOT need `elixir` to run your app, assuming your mix release configures `include_erts: true` (which is the default).

Add `freebsd` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:freebsd, "~> 0.5.0", runtime: false}
  ]
end
```

Add a `freebsd` key to `mix.exs` project config.

```elixir
  def project do
    [
      # ExFreeBSD requires these standard keys:
      app: :freebsd,
      version: "0.5.0",
      description: description(),
      homepage_url: "https://github.com/patmaddox/ex_freebsd",
      # and adds this one:
      freebsd: freebsd()
    ]
  end

  defp freebsd do
    %{
      # required
      maintainer: "pat@patmaddox.com",
      description: description(), # can be a multi-line string instead

      # optional, documented at https://www.freebsd.org/cgi/man.cgi?pkg-create(8)
      deps: %{
        bash: %{version: "5.1", origin: "shells/bash"}
      }
    }
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

## Choosing an OTP Version

The simplest way to install and build with elixir is to `pkg install elixir`.
This will use the most recently built [`lang/elixir`](https://www.freshports.org/lang/elixir/)
and [`lang/erlang`](https://www.freshports.org/lang/erlang/) ports.

If you want to use a more recent version of elixir, and specify your erlang/OTP version,
you should install [`lang/elixir-devel`](https://www.freshports.org/lang/elixir-devel/) and
 the [`elixir-runtime*`](https://www.freshports.org/search.php?query=erlang-runtime&search=go&num=10&stype=name&method=match&deleted=excludedeleted&start=1&casesensitivity=caseinsensitive)
 you want.

The key difference between `lang/erlang` and `lang/erlang-runtime*` is that `lang/erlang` installs the erlang tools
to `/usr/local/bin`, and `lang/erlang-runtime*` do not. This means that you will explicitly need to add the package's
bin path to your PATH to use the tools, e.g. `export PATH=/usr/local/lib/erlang25/bin:$PATH`.

See `.cirrus.yml` for an example of how to install and configure a specific erlang runtime.
(Note that PATH is set using Cirrus CI's [env var syntax](https://cirrus-ci.org/guide/writing-tasks/#environment-variables).

## Roadmap

- auto-name package w/ CI suffix: `<app>-ci-<branch>-<version>p<timestamp>`
- MANIFEST conflict for `<app> <app>-ci-*`
- run as non-privileged user
- document epmd usage (run it as a service, not automatically by package)
- build package as part of a release