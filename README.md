# gitlocal

A [pre-commit](https://pre-commit.com) hook that prevents committing files marked as local-only. If your CLI tool generates credentials or machine-specific config inside a project directory, you can drop an empty `.gitlocal` marker file next to them and this hook will block any attempt to commit files from that directory.

There are three ways to mark files:

An empty `.gitlocal` file in a directory marks the whole directory:

```
.sometool/
  config.json
  credentials.json
  .gitlocal
```

A `.gitlocal` extension on a standalone file marks that individual file, so a tool that writes `credentials.gitlocal` instead of `credentials.json` gets the same protection without needing a directory.

A `# gitlocal` comment on the first line of a text file marks it directly, which handles cases where the tool doesn't control the filename but the format supports comments (shell, YAML, TOML, Ruby, Python, INI).

Trying to commit any of these produces:

```
$ git commit
gitlocal: blocked commit of local-only files:

  .sometool/credentials.json (marked by .sometool/.gitlocal)

Remove these files from staging with: git reset HEAD <file>
```

If you genuinely need to commit a marked file, `git commit --no-verify` skips all pre-commit hooks including this one.

## Installation

Add to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/andrew/gitlocal
    rev: v0.1.0
    hooks:
      - id: gitlocal
```

Then `pre-commit install`.

## License

MIT
