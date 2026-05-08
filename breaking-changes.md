# Yazi v26.5.6 Breaking Changes

Notes on what broke between v26.1.22 and v26.5.6, and the upgrade strategy.

## Config changes required

### 1. `$schema` keys rejected
Remove from all `.toml` files:
```toml
"$schema" = "https://yazi-rs.github.io/schemas/yazi.json"
```

### 2. Fetchers require `group` field (`yazi.toml`)
```toml
# Before
{ id = "mime", url = "*/", run = "mime.dir", prio = "high" }
# After
{ id = "mime", group = "mime", url = "*/", run = "mime.dir", prio = "high" }
```

### 3. `[tasks]` worker keys renamed (`yazi.toml`)
```toml
# Before
micro_workers = 10
macro_workers = 10

# After
file_workers    = 3
plugin_workers  = 5
fetch_workers   = 5
preload_workers = 2
process_workers = 5
```

### 4. `title_format` removed from `[mgr]` (`yazi.toml`)
Key is gone entirely. Replaced by the `ind-app-title` DDS event in Lua.

### 5. `name` renamed to `url` in filetype rules (`flavor.toml`)
```toml
# Before
{ name = "*", fg = "#3B3B3B" }
# After
{ url = "*", fg = "#3B3B3B" }
```

### 6. `tab_width` type changed (`flavor.toml`)
Value must now be a string, not an integer:
```toml
# Before
tab_width = 1
# After
tab_width = "1"
```

## Lua breaking changes

- **Lua 5.5 upgrade** — may affect plugins using deprecated Lua patterns
- **`ui.Style` made immutable** — affects plugins that mutate styles in-place

## Installing v26.1.22

`cargo install --force yazi-build` is broken on this version (missing Lua files on crates.io).
Use the GitHub release binary directly:

```sh
YAZI_VERSION="26.1.22"
curl -L "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-aarch64-apple-darwin.zip" -o /tmp/yazi.zip
unzip -o /tmp/yazi.zip -d /tmp/yazi-install/
cp /tmp/yazi-install/yazi-aarch64-apple-darwin/yazi ~/.cargo/bin/yazi
cp /tmp/yazi-install/yazi-aarch64-apple-darwin/ya ~/.cargo/bin/ya
chmod +x ~/.cargo/bin/yazi ~/.cargo/bin/ya
rm -rf /tmp/yazi.zip /tmp/yazi-install
```

## Upgrade strategy

Config is close to vanilla so migration is straightforward when ready:

1. Strip all `$schema` keys
2. Replace `micro_workers`/`macro_workers` with the 5-key worker split
3. Add `group` field to fetcher rules
4. Check `name` → `url` in any filetype/flavor rules
5. Fix `tab_width` string type in flavor
6. Remove `title_format` (or replace with `ind-app-title` DDS event if needed)
7. Test Lua plugins against Lua 5.5 and immutable `ui.Style`

Keeping config minimal and close to defaults reduces this surface area for future upgrades.
