# Sample `.bashrc`: Admin Welcome Banner

A sample [`.bashrc`](.bashrc) for the University Library's Ubuntu server, used
alongside COMP-175 Module 3 (File Systems & Storage). On every new
interactive shell it prints a short status report -- who you are, what
filesystem you're on, and how much space is left -- built entirely from
commands the module itself teaches: `id`, `groups`, `mount`, `df`.

## Try it

```
cd ~
curl -O https://raw.githubusercontent.com/SE4CPS/2026-COMP-175/main/modules/module-3/dotfiles/.bashrc
cat .bashrc >> ~/.bashrc
source ~/.bashrc
```

(Or just read the file -- it's short and commented, meant to be understood,
not just copy-pasted.)

## What it shows, and why

| Line in the banner | Command behind it | Ties back to |
|---|---|---|
| Your identity / your groups | `id`, `groups` | Module 3: Ownership |
| Root filesystem type | `mount \| grep ' on / '` | Module 3: What Is a File System? |
| Disk space on `/` and `/srv` | `df -h` | Same slide, the other half |
| `/var` usage warning | `df -h /var` | Module 3: FHS -- `/var: Where the Changes Go` |

## Why this is worth reading, not just running

A login banner is a real, everyday admin habit: on a shared server, the
first few seconds after logging in should tell you who you are, whether
you're about to run out of disk, and what you're actually working with --
before you type a single other command. This file is a small, honest
example of that habit, not a toy.
