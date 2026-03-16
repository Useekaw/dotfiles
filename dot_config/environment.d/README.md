# environment.d

Configuration files for the systemd user environment, parsed by
`systemd-environment-d-generator(8)`.

## Format

Plain `KEY=VALUE` assignments, one per line. No shell syntax, no `export`.

```ini
FOO=bar
MY_PATH=/usr/local/bin:$PATH
```

Variable references via `$VAR` or `${VAR}` are supported.

## File Naming

Files must have a `.conf` extension. Numeric prefixes are recommended to
control load order:

```
10-defaults.conf
60-overrides.conf
```

Files are processed in lexicographic order. Later filenames take precedence
over earlier ones.

## Lookup Paths (user)

| Path                                  | Purpose                        |
|---------------------------------------|--------------------------------|
| `~/.config/environment.d/*.conf`      | User-level config              |
| `/etc/environment.d/*.conf`           | System-wide admin overrides    |
| `/run/environment.d/*.conf`           | Runtime overrides              |
| `/usr/lib/environment.d/*.conf`       | Vendor/package defaults        |

Files in `/etc/` override `/run/`, which overrides `/usr/lib/`.

## Scope

Variables are inherited by all services started under the **systemd user
instance** — not by login shells or system-level services.
