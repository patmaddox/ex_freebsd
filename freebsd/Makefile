PORTNAME= freebsd
PORTVERSION= 0.1.0
CATEGORIES= patmaddox

MAINTAINER= pat@patmaddox.com
COMMENT= mix tasks for converting Elixir projects to FreeBSD packages.

USE_LOCALE= en_US.UTF-8

NO_CHECKSUM= yes
BUILD_DEPENDS= elixir>=1.13.4:lang/elixir

USE_GITHUB= yes
GH_ACCOUNT= patmaddox
GH_PROJECT= ex_freebsd
GH_TAGNAME= tbd

MIX_ENV= prod

do-build:
	HOME=$(WRKSRC) LANG="$(USE_LOCALE)" LC_ALL="$(USE_LOCALE)" mix local.hex --force
	HOME=$(WRKSRC) LANG="$(USE_LOCALE)" LC_ALL="$(USE_LOCALE)" mix local.rebar --force
	cd $(WRKSRC) && HOME=$(WRKSRC) MIX_ENV=$(MIX_ENV) LANG="$(USE_LOCALE)" LC_ALL="$(USE_LOCALE)" mix deps.get
	cd $(WRKSRC) && HOME=$(WRKSRC) MIX_ENV=$(MIX_ENV) LANG="$(USE_LOCALE)" LC_ALL="$(USE_LOCALE)" mix release

do-install:
	mkdir -p $(STAGEDIR)$(PREFIX)/libexec/$(BASENAME)
	cp -R $(WRKSRC)/_build/$(MIX_ENV)/rel/$(BASENAME)/ $(STAGEDIR)$(PREFIX)/libexec/$(BASENAME)
	ln -s $(PREFIX)/libexec/$(BASENAME)/bin/$(BASENAME) $(STAGEDIR)$(PREFIX)/bin/$(BASENAME)
	cd $(STAGEDIR)$(PREFIX) && find * -type f -or -type l >> $(TMPPLIST)

.include <bsd.port.mk>
