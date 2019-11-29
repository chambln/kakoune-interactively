# Interactively

This plugin provides makes various [Kakoune](https://kakoune.org)
commands more friendly and interactive.

[![asciicast](https://asciinema.org/a/F5UXtFxv6PjCnZnU05EFSxIzJ.svg)](https://asciinema.org/a/F5UXtFxv6PjCnZnU05EFSxIzJ)

For example, `i-write` writes the buffer; if the file is write protected, it
shows a yes-or-no prompt, ‘Ignore write protection?’; if its parent directory
doesn’t exist, ‘Create directory? (/path/to/its/directory)’. Extending this,
`i-delete-buffer` will ask before deleting a modified buffer, ‘Save changes?’
and run `i-write` if so. Furthermore, `i-quit` does this for each buffer
before quitting.

Example configuration:

```kak
# ~/.config/kak/kakrc
plug chambln/kakoune-interactively config %{
    map global user d ': i-delete-buffer<ret>'
    map global user q ': i-quit<ret>'
    map global user w ': i-write<ret>'
    set-option global yes_or_no_instant true
}
```
