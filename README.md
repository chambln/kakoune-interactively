# Interactively

This plugin makes various [Kakoune](https://kakoune.org) commands more
friendly and interactive by asking questions such as ‘save changes?’ and
‘ignore write protection?’. In particular, `i-quit` saves you the
trouble of hunting down modified buffers to save (or discard) before
quitting.

[![asciicast](https://asciinema.org/a/F5UXtFxv6PjCnZnU05EFSxIzJ.svg)](https://asciinema.org/a/F5UXtFxv6PjCnZnU05EFSxIzJ)

Suggested configuration:

``` kak
# ~/.config/kak/kakrc
plug chambln/kakoune-interactively config %{
    alias global db i-delete-buffer
    alias global q i-quit
    alias global w i-write
    alias global cd i-change-directory
    set-option global yes_or_no_instant true
}
```

If `yes_or_no_instant` is truthy then `yes-or-no` prompts will not wait
for <kbd>ret</kbd> to be pressed.

You can use `yes-or-no` to create your own interactions. Prompts happen
asynchronously, so Kakoune won’t wait for the prompt to be dismissed
before continuing with the next line of the script. To work around this,
`yes-or-no` accepts an optional parameter `<final>` which it evaluates
after a yes or no answer is given. If the prompt is dismissed with
<kbd>Esc</kbd>, nothing is evaluated.

## Bugs

  - `i-delete-buffer` is too keen on writing scratch buffers before
    deleting them
  - `i-write` is too quick to conclude that the file is write protected
