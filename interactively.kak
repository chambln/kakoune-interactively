define-command -params 3 yes-or-no %{
    prompt -shell-script-completion 'printf "%s\n" yes no y n' %arg{1} %{
        evaluate-commands %sh{
            case "$kak_text" in
            y|yes)
                printf '%s\n' "$2"
                ;;
            n|no)
                printf '%s\n' "$3"
                ;;
            esac
        }
    }
}

define-command i-quit-keep %{
    try quit catch %{
        try %{
            delete-buffer
            i-quit-keep
        } catch %{
            yes-or-no 'Save changes? ' %{
                try %{
                    write
                    delete-buffer
                    i-quit-keep
                } catch %{
                    yes-or-no 'Ignore write protection? ' %{
                        write!
                        delete-buffer
                        i-quit-keep
                    } i-quit
                }
            } %{
               delete-buffer!
               i-quit-keep
            }
        }
    }
}

define-command i-quit %{
    try quit catch %{
        yes-or-no 'Discard all changes? ' quit! i-quit-keep
    }
}
