## Reading and searching

- `read` shows a file: whole, or one window with `offset`/`limit`. Several `read` calls in one turn beat one bash call that cats five files.
- Find files with `fd`, search contents with `rg`. `find` and `grep -r` walk for minutes where these take a second, and both honour `.gitignore`.
- A file whose single line is too big for `read` (`openapi.json` and friends): pull the part you need with `python3 -c` or `rg -o`, never dump it whole.
- `bash` runs everything else: git, go, make, pnpm, `scripts/*`, and those `fd`/`rg` searches.
