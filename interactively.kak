define-command -params 3..4 yes-or-no %{
    prompt -shell-script-completion 'printf "%s\n" yes no y n' %arg{1} %{
        evaluate-commands %sh{
            case "$kak_text" in
            y|yes)
                printf '%s\n' "$2" "$4"
                ;;
            n|no)
                printf '%s\n' "$3" "$4"
                ;;
            esac
        }
    }
}

define-command mkdir %{
    echo %sh{
        mkdir -pv "$(dirname "$kak_buffile")"
    }
}

define-command \
-params ..3 \
-docstring "i-write [<commands1> [<commands2> [<commands3>]]]

Interactively write the buffer. Evaluate commands1 if successful else
commands2. Finally evaluate commands3." \
i-write %{
    try %{
        write
        evaluate-commands "%arg{1}"
        evaluate-commands "%arg{3}"
    } catch %{
        evaluate-commands %sh{
            dir="$(dirname "$kak_buffile")"
            if [ ! -d "$dir" ]; then
                printf '%s\n' "yes-or-no 'Create directory? ($dir) ' %{
                                   mkdir
                                   i-write %{$1} %{$2} %{$3}
                               } %{$2} %{$3}"
            else
                printf '%s\n' "yes-or-no 'Ignore write protection? ' %{
                                   write!
                                   $1
                               } %{$2} %{$3}"
            fi
        }
    }
}

define-command \
-params 3 \
-docstring "i-delete-buffer [<commands1> [<commands2> [<commands3>]]]

Interactively delete the buffer. Evaluate commands1 if successful else
commands2. Finally evaluate commands3." \
i-delete-buffer %{
    try %{
        delete-buffer
        evaluate-commands "%arg{1}"
        evaluate-commands "%arg{3}"
    } catch %{
        evaluate-commands %sh{
            printf '%s\n' "yes-or-no 'Save changes? ' %{
                               i-write %{
                                   delete-buffer
                                   $1
                               } %{$2} %{$3}
                           } %{
                               delete-buffer!
                               $1
                               $3
                           }"
        }
    }
}

define-command i-quit-keep %{
    try quit catch %{
        i-delete-buffer i-quit-keep i-quit nop
    }
}

define-command i-quit %{
    try quit catch %{
        yes-or-no 'Discard all changes? ' quit! i-quit-keep
    }
}
