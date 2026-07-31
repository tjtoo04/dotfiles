# GNU Stow — dotfile management guide

GNU Stow is a **symlink farm manager**. You keep your dotfiles in a version-controlled
directory (this repo), and Stow creates symlinks in your home directory pointing back
to the real files. Editing `~/.config/ghostty/config` is actually editing the file in
this repo — one source of truth, one `git commit` to sync every machine.

This repo already uses Stow: every top-level folder (`ghostty/`, `nvim/`, `waybar/`, …)
is a **package**, and `./install.sh` runs `stow -R` on all of them.

---

## 1. Installation

```bash
# Arch
sudo pacman -S stow

# Debian / Ubuntu
sudo apt install stow

# Fedora
sudo dnf install stow

# macOS
brew install stow

# Anywhere (GNU systems)
# build from https://ftp.gnu.org/gnu/stow/
```

Verify:

```bash
stow --version   # GNU Stow version 2.4.0 (or similar)
```

---

## 2. Core concepts

Stow has three pieces of vocabulary. Get these and everything else follows.

| Term | Meaning | In this repo |
| ------ | --------- | -------------- |
| **Stow directory** | The repo holding your packages | `~/dotfiles` |
| **Target directory** | Where symlinks get created | `~` (your home dir) |
| **Package** | A folder whose contents get linked | `ghostty/`, `nvim/`, `mako/`, … |

The trick that makes it work: a package's internal structure mirrors the target.
`ghostty/.config/ghostty/config` maps to `~/.config/ghostty/config`, because
Stow creates a symlink for every path *inside* the package.

---

## 3. The commands

All commands are run **from inside the stow directory** (`cd ~/dotfiles`).

### `stow <package>` — create links

```bash
stow ghostty
```

Creates `~/.config/ghostty` as a symlink to `ghostty/.config/ghostty`.

### `stow -D <package>` — remove links

```bash
stow -D ghostty
```

Removes the symlinks Stow created. **It does not delete your repo files.**

### `stow -R <package>` — restow (delete + stow)

```bash
stow -R ghostty
```

Useful after you've moved files *inside* a package, or to re-sync after a
`git pull`. This is what `install.sh` uses for every package.

### `stow -n` — simulate (dry run)

```bash
stow -n -v ghostty
```

Shows what *would* happen without touching anything. **Always run this first
when something feels off.**

### `stow -v` / `stow -vv` — verbosity

```bash
stow -v ghostty        # shows what it links
stow -vv ghostty       # even more detail
```

Combine with `-n` for a safe preview: `stow -nv ghostty`.

### `stow --adopt` — bring an existing file into the repo

```bash
stow --adopt ghostty
```

This is the magic one for onboarding a new config (see §5). Stow moves an
already-existing target file *into* the package (adopts it), then links it.

---

## 4. How this repo works

```text
~/dotfiles
├── ghostty/          ─┐
├── nvim/              │  each top-level dir is a package
├── waybar/            │  containing e.g. .config/<app>/…
├── mako/             ─┘
├── install.sh
└── packages.txt
```

`install.sh` does the equivalent of:

```bash
cd ~/dotfiles
for dir in ghostty nvim waybar mako …; do
    stow -R "$dir"
done
```

### Add a brand-new package manually

```bash
cd ~/dotfiles
mkdir -p newapp/.config/newapp   # mirrors target layout
# … put your config file in there …
stow -n newapp                   # preview
stow newapp                      # link it
```

### Use the `--adopt` flow for an existing config (recommended)

```bash
cd ~/dotfiles
mkdir -p newapp/.config
stow -nv --adopt newapp          # see what it would adopt
stow --adopt newapp              # moves ~/.config/newapp INTO the repo and links it
```

After adopting, review the file and `git add` it. `--adopt` is safe because it
only moves files that aren't already symlinks (Stow refuses to touch symlinks
owned by other packages), but still **run `git diff` before committing** —
the adopted file is now the live one.

---

## 5. Typical workflow

```bash
# edit a config — it's just a file in this repo
$EDITOR ~/.config/ghostty/config     # actually editing ghostty/.config/ghostty/config

git add ghostty && git commit -m "tweak ghostty font size"   # you decide when to commit

# on a new machine
git clone <url> ~/dotfiles
cd ~/dotfiles
./install.sh                         # links everything at once
```

---

## 6. Pitfalls & troubleshooting

### "Existing target is not owned by stow"

```text
existing target is not owned by stow: /home/user/.config/foo
```

Something already lives at the target path that isn't a symlink (or is a
symlink to somewhere else). Fix options:

```bash
stow --adopt foo     # if it's a config you want to keep: pull it into the repo
rm ~/.config/foo && stow foo    # if it's junk you want gone
stow -n -v foo       # if unsure, always preview first
```

### Stow created a directory instead of a symlink

If a package contains a *directory* with files, Stow symlinks the directory —
e.g. `~/.config/ghostty -> ../dotfiles/ghostty/.config/ghostty`. That's normal
and desirable. If you'd rather link individual files (so you can add more files
to the target without them appearing in the repo), pass `--no-folding`:

```bash
stow --no-folding ghostty
```

### A package is getting huge / you want to ignore files

Create a `.stow-local-ignore` file inside the package. Default ignore patterns
(like `.git/`, editor swap files) are already handled; the local file adds yours:

```bash
# ghostty/.stow-local-ignore
\.DS_Store
.*\.swp
```

### Check the damage before doing anything

```bash
stow -nvvv <package>   # three v's: maximum detail dry run
```

### `~/.config/foo` symlink is dangling

The repo file was moved/deleted but the link wasn't. Fix with a restow:

```bash
stow -R foo
```

If it's *still* dangling, the file genuinely doesn't exist in the repo — check
the package contents, or `stow -D foo && stow foo`.

### Multiple packages colliding on the same path

If two packages both want to own `~/.config/foo`, Stow will report a conflict.
Give each app its own package dir (that's why this repo has one dir per app)
or split the files between packages — one owner per path, always.

---

## 7. Cheat sheet

```bash
cd ~/dotfiles

stow foo              # link foo's files into ~
stow -D foo           # unlink foo
stow -R foo           # relink foo (delete + stow)
stow --adopt foo      # pull existing ~ files into repo, then link
stow --no-folding foo # link individual files instead of the whole dir
stow -n -v foo        # dry run with details — your safety net
stow -nvvv foo        # maximum paranoid dry run
./install.sh          # stow -R everything
```

---

## 8. Further reading

- Official manual: <https://www.gnu.org/software/stow/manual/>
- `man stow` — the man page is excellent
- Info pages: `info stow`
