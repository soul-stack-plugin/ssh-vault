# ssh-vault

Supplies SSH credentials to `keeper.push` from the Vault SSH secrets engine.

A Soul Stack **SshProvider** plugin, built as `soul-ssh-vault` and launched by the host over
gRPC-over-stdio. It is its own Go module and depends on the core through two
PUBLISHED ones only — `sdk` and `proto/plugin` — with no `replace`, which is what
makes this repository buildable on its own ([ADR-011][adr11]).

`schema.json` is a `kind: ssh_provider` document and is HAND-MAINTAINED — nothing regenerates it. `make manifest` validates it with `soul-lint`.

## Build and check

```sh
make check      # fmt, vet, no-replace, tests, and the schema/manifest gate
make build      # dist/soul-ssh-vault
```

`make no-replace` is not decoration: a `replace` in `go.mod` would make this
repository buildable only next to a checkout of soul-stack, which is exactly what
moving it out of `examples/module/` undid.

## Where this came from

It lived in `soul-stack/examples/module/soul-ssh-vault` until NIM-825. [ADR-011][adr11]
reserves `examples/` for non-Go artifacts — "Runnable Go examples go in `tools/`
or separate repos" — and six Go modules had accumulated there against it. The
sources did not change in the move; the published schema document is byte-identical.

## Licence

Apache 2.0 — see [LICENSE](LICENSE). Permissive by design: every plugin statically
links the generated `pluginv1` stubs, so anything less would leak into third-party
plugin binaries (ADR-016).

[adr11]: https://github.com/souls-guild/soul-stack/blob/main/docs/adr/0011-go-layout.md
