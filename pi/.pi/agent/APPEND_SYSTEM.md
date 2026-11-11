## Reading and searching

- `read` is the way to see a file: whole file, or one window with `offset`/`limit`. Several `read` calls in one turn beat one bash call that cats five files.
- A file whose single line is too big for `read` (`openapi.json` and friends): extract the part you need with `python3 -c` or `rg -o`, never dump it whole.
- The `grep` and `find` tools are rg and fd — a second where `find`/`grep` walk for minutes across `/mnt/*`, and they honour `.gitignore`. Everything that is not a plain `read` goes through these two.
- `bash` runs commands: git, go, make, pnpm, `scripts/*`. Reading and searching belong to the tools above.
