# Small Shell

A simple command shell implementation in C that supports basic shell operations.

## Features

- Command execution in foreground and background
- Input/output redirection (`>`, `<`, `>>`)
- Built-in commands (`exit`, `cd`, `status`)
- Signal handling (SIGINT, SIGCHLD, SIGTSTP)
- Comment support (lines starting with `#`)
- Background process execution with `&`

## Usage

```bash
./smallsh
```

## Examples

```bash
# Run a command
ls -la

# Background execution
sleep 10 &

# Input/output redirection
echo "hello" > output.txt
cat < input.txt

# Built-in commands
cd /home/user
status
exit
```

## Building

```bash
gcc -o smallsh smallsh.c
```