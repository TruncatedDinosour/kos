# Kos

<p align="center">
  <img src="https://img.shields.io/github/last-commit/TruncatedDinosour/kos?color=red&style=flat-square">
  <img src="https://img.shields.io/github/repo-size/TruncatedDinosour/kos?color=red&style=flat-square">
  <img src="https://img.shields.io/github/issues/TruncatedDinosour/kos?color=red&style=flat-square">
  <img src="https://img.shields.io/github/stars/TruncatedDinosour/kos?color=red&style=flat-square">
</p>

> A simple SUID tool written in C++

# Requirements

- Pkg-config: https://www.freedesktop.org/wiki/Software/pkg-config/
- Libxcrypt: https://github.com/besser82/libxcrypt

# Third party software support

- [Bash completion](https://github.com/scop/bash-completion) (Install `completions/kos.bash` into `/usr/share/bash-completion/completions/kos`)

# Known issues

- Only supported on Linux

```
shadow.h is one of the requirements of kos which is a "linux thing",
so automatically won't work on something like OpenBSD, MacOS, SerenityOS or
any other OSes.

Kos will not work on any non-unix OSes as kos uses a lot of
unix stuff, for example pwd.h, meaning will not work on stuff
like Windows and other non-unix OSes.

Though this is not really a big issue, this app is meant to
be ran on linux and was made with the intention to be used on
and with linux...
```

- Overcomplicated `input_no_echo()` function

```
I used that function because it's literally the only
way I know how to disable eching of STDIN in linux with
C++ without using some huge lib like GNU readline or something...
```

# People packaging kos for non-corporate use

```
I, the creator of kos, permit you to use any of these licenses:

- GPLv3
- BSD 3-clause
- ArAr2

If you do not want to bundle ArAr2 license together you are free
to use any of the other ones
```

# Building and installing

_If you are `root` you do not need to use `su`, just run commands directly_

## Manual

### Building

```sh
CXXFLAGS='-D_KOS_VERSION="1"' CXX=g++ ./scripts/build.sh  # Compiles with GCC instead of Clang (default)
```

`CXXFLAGS='-D_KOS_VERSION="1"'` is important as it will define version argument

### Installing

```sh
./scripts/strip.sh kos
su -c 'mkdir -p /usr/local/bin'
su -c 'chown root:root ./kos'
su -c 'install -Dm4711 ./kos /usr/local/bin'
```

### [Man page](https://man-db.nongnu.org/) installation

```sh
su -c 'mkdir -p /usr/share/man/man1'
su -c 'install -Dm0644 kos.1 /usr/share/man/man1/kos.1'
su -c 'mandb -qf /usr/share/man/man1/kos.1'
```

### Completions

#### Bash

```sh
su -c 'cp completions/kos.bash /usr/share/bash-completion/completions/kos'
```

## Automated

Before running the script you can optionally:

- Set the `DO_STRIP` environment variable to strip the binary after compilation
- Set the `INSTALL_MAN` environment variable to also install man page
- Set the `INSTALL_BCOMP` environment variable to also install bash completion

```sh
chmod a+rx ./scripts/setup.sh
su -c './scripts/setup.sh'
```

# Logic

```
Compile program linking the libxcrypt lib, then
give it suid privelages using 4711 permissions,
the program executable should also be owned by the root
user and group, program should first check
if a command is supplied as not to
trigger any bugs, then we validate that the
user is in a master, by default kos, group and if
that passes we go on to validate the password using passwd
struct for getting the username of current logged in user,
getuid() for getting uid of current user and then getting
/etc/shadow entry using <shadow.h> for that specific user
after that we ask for the user to enter their password
and we do not echo STDIN, we wait for the user to hit enter and then
we hash the password using crypt() function of libxcrypt
and compare it to pw->sp_pwdp where pw is the spwd struct
which is the shadow entry of currently logged in user, if everything
is okay return true, else return false, if it passes we continue
and call setuid() and setgid(), we check if they fail,
if no, continue, else notify the user, then we
increment the argv pointer array to ignore argv[0] which
is the program name and call run_command() on it,
then in that function we fork the current process
and check if it succeeded, if no we notify the user,
else we contnue, if the currect process is in child we call
execvp() and run the command, if in parent we waitpid() the
child and get the exit code, which we return and then
finally we just exit with the code the child process
exited with
```

# Note for packagers

- Arch Linux

```
Permission issues (ERROR: Failed getting groups for user ...)
    The issue can be solved with one install command:
    $ install -Dm4755 -o root "$srcdir/$pkgname-$pkgver/kos" "$pkgdir/usr/bin/kos"
```

# Packages

- Gentoo Linux:
  - [app-admin/kos::dinolay](https://ari-web.xyz/gentooatom/app-admin/kos)
- Arch Linux
  - [AUR/kos@moonaru](https://aur.archlinux.org/packages/kos)

# Tips

- If you're building for size make sure to build with `-Os` or `-Oz` in `CXXFLAGS`
  as it barely touches start times but it decreases the size largely, stripping
  can help too
- By default kos has modifying of the environment (I.e. USER, HOME, ...) enabled, this
  increases the size by 39KB (no optimisation), if you want to not set the env and have
  a smaller binary, disable that in `config.h` by commenting out the definition
- If you every want to debug kos use `-g -Og` CXXFLAGS

# Testing

There are two scripts in the [testing scripts](/scripts/test) directory,
one is `noroot.sh` and other `root.sh`, `*.lib.sh` are just
libs.

If you want to test it you just run the scripts, though which ones?

- If you have access to root run: `root.sh`
- If you have access to a non-privileged user run: `noroot.sh`
- If you have access to both run.. Well both

## Highly recommended

- Run [valgrind](https://valgrind.org/info/about.html) on kos

```sh
CXXFLAGS='-Og -g' ./scripts/build.sh
valgrind ./kos
valgrind -s ./kos
```

Or run [valgrind.sh](/scripts/test/valgrind.sh) testing script,
will test all compilers, tools and stuff, in general a much more
in-depth test

Returns code `127` on failure (detection of a memory leak) and
you can see the log file in `valgrind.log`

## Requirements

- Clang
- GCC
- Coreutils
- Bash
- [Net-tools](http://net-tools.sourceforge.net/) (or a `hostname` command)

## Net-tools is not a thing for me!

You can easily make your own `hostname` command which is the
only thing testing depends on:

```sh
#!/usr/bin/env sh
cat /etc/hostname
```

Add this to /usr/bin/hostname and make it executable:

```sh
su -c 'chmod 755 /usr/bin/hostname'
```

# Using as a header

Just define `KOS_H` before including the `main.cpp` file

# Inputting password from external sources

**This section only applies if `HAVE_PIPE` is set**

`Kos` supports piping to STDIN so you can easily just
pipe (`|`) the password to STDIN :)

For example:

```sh
echo 'Top-secret-passw0rd' | kos id
```

Or even

```sh
printf '' | dmenu -l 0 -p 'Password: ' | kos id
```
