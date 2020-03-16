```
Usage: mc [<flags>] <command_to_memoize>
Memoizes the output of a given command.

Commands
  command_to_memoize        Command string to execute and memoize the result of

Flags
  --update | -u             Execute the command and update the cache with the new output
  --flush | -f              Flush the cache

Notes
  - Stores a cache of memoized command outputs in the home folder.
  - Caches the command under the command string and the current directory path

Dependencies
  - jq: https://stedolan.github.io/jq
```
