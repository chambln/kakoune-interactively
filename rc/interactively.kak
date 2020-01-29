declare-option bool yes_or_no_instant false

define-command \
-hidden \
-command-completion \
-params 3..4 \
yes-or-no-instant %{
    prompt "%arg{1} ([a]bort, [y]es, [n]o) " \
    -shell-script-completion 'printf "%s\n" abort yes no a y n' \
    %{
        evaluate-commands %sh{
            case "$kak_text" in
            y|yes)
                printf '%s\n' 'exec <ret>' "$2" "$4"
                ;;
            n|no)
                printf '%s\n' 'exec <ret>' "$3" "$4"
                ;;
            esac
        }
    }
}

define-command \
-hidden \
-command-completion \
-params 3..4 \
yes-or-no-patient %{
    prompt "%arg{1} ([a]bort, [y]es, [n]o) " \
    -shell-script-completion 'printf "%s\n" abort yes no a y n' \
    %{
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

define-command \
-command-completion \
-params 3..4 \
-docstring "
    yes-or-no <prompt> <consequent> <alternative> [<final>]:
    evaluate <consequent> if ‘y’ pressed, <alternative> if ‘n’
    pressed; finally evaluate <final>; if the prompt is dismissed with
    <esc>, evaluate nothing" \
yes-or-no %{
    evaluate-commands %sh{
            case "$kak_opt_yes_or_no_instant" in
            true)
                printf '%s\n' 'yes-or-no-instant %arg{@}'
                ;;
            false)
                printf '%s\n' 'yes-or-no-patient %arg{@}'
                ;;
            esac
    }
}

define-command \
-params ..3 \
-docstring "
    i-write [<consequent> [<alternative> [<final>]]]: interactively
    write the buffer; evaluate <consequent> if successful else
    <alternative>; finally evaluate <final>" \
i-write %{
    try %{
        write
        evaluate-commands "%arg{1}"
        evaluate-commands "%arg{3}"
    } catch %{
        evaluate-commands %sh{
            case "$kak_buffile" in
            /*)
                dir="$(dirname "$kak_buffile")"
                if [ ! -d "$dir" ]; then
                    printf '%s\n' "i-mkdir '$dir' %{
                                       i-write %{$1} %{$2} %{$3}
                                   } %{$2} %{$3}"
                else
                    printf '%s\n' "yes-or-no 'Ignore write protection?' %{
                                       write!
                                       $1
                                   } %{$2} %{$3}"
                fi
                ;;
            *)
                printf '%s\n' "execute-keys ': write '"
                ;;
            esac
        }
    }
}

define-command \
-params ..3 \
-docstring "
    i-delete-buffer [<consequent> [<alternative> [<final>]]]:
    interactively delete the buffer; evaluate <consequent> if successful
    else <alternative>; finally evaluate <final>" \
i-delete-buffer %{
    try %{
        delete-buffer
        evaluate-commands "%arg{1}"
        evaluate-commands "%arg{3}"
    } catch %{
        evaluate-commands %sh{
            printf '%s\n' "yes-or-no 'Save changes?' %{
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

define-command -hidden i-quit-keep %{
    try quit catch %{
        i-delete-buffer i-quit-keep i-quit nop
    }
}

define-command \
-docstring "
    i-quit: interactively quit" \
i-quit %{
    try quit catch %{
        yes-or-no 'Discard all changes?' quit! i-quit-keep
    }
}

define-command -hidden i-kill-keep %{
    try kill catch %{
        i-delete-buffer i-kill-keep i-kill nop
    }
}

define-command \
-docstring "
    i-quit: interactively quit" \
i-kill %{
    try kill catch %{
        yes-or-no 'Discard all changes?' kill! i-kill-keep
    }
}

define-command \
-file-completion \
-params 1..4 \
-docstring "
    i-mkdir <directory> [<consequent> [<alternative> [<final>]]]:
    interactively create <directory>; evaluate <consequent> if successful
    else <alternative>; finally evaluate <final>" \
i-mkdir %{
    evaluate-commands %sh{
        printf '%s\n' "yes-or-no 'Create directory? ($1)' %{
                           echo %sh{ mkdir -pv '$1' | sed '\$!d' }
                           $2
                       } %{$3} %{$4}"
    }
}

define-command \
-params 1..4 \
-file-completion \
-docstring "
    i-change-directory <target> [<consequent> [<alternative> [<final>]]]:
    interactively change the working directory to <target> or the
    directory containing <target>; evaluate <consequent> if successful
    else <alternative>; finally evaluate <final>" \
i-change-directory %{
    try %{
        change-directory %arg{1}
    } catch %{
        evaluate-commands %sh{
            if [ -e "$1" ]; then
                printf "change-directory '%s'" "$(dirname "$1")"
            else
                printf '%s\n' "i-mkdir '$1' %{
                                   i-change-directory %{$1} %{$2} %{$3} %{$4}
                               } nop nop"
            fi
        }
    }
 }
