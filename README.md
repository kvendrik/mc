# Memoize Command
### Memoizes the output of a given command

#### Demo
![Command line in which the first command run takes 5 seconds and subsequential runs take less than 1](demo.gif)

#### Help
```
Usage: mc [<flags>] <command_to_memoize>
Memoizes the output of a given command.

Commands
  command_to_memoize        Command string to execute and memoize the result of

Flags
  --update | -u             Execute the command and update the cache with the new output
  --flush | -f              Flush the cache
  --project | -p            Makes the cache key generation project specific by adding the
                            project path and branch name to it (if it's a Git repository).
                            This way you can maintain different cached outputs for the same
                            command based on the folder and Git branch you call it in.

Notes
  - Stores a cache of memoized command outputs in the home folder
  - Caches the command under the command string unless the --project flag is given
```
