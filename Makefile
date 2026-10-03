# convenience targets that mirror the ci pipeline (.github/workflows/ci.yml).
# run `make help` for the list.
.PHONY: help test lint docs docs-check check

help:
	@echo "targets:"
	@echo "  test        run the busted suite"
	@echo "  lint        run luacheck over src/"
	@echo "  docs        regenerate the ldoc api docs in place (docs/)"
	@echo "  docs-check  fail if committed docs/ differs from a fresh build"
	@echo "  check       lint + test + docs-check"

test:
	busted --no-coverage -o utfTerminal

lint:
	luacheck src/ --no-unused-args --no-max-line-length --globals _G _TEST

# the nginx vhost serves docs/ directly, so regenerating here updates the site
docs:
	ldoc .

docs-check:
	./scripts/check-docs.sh

check: lint test docs-check
