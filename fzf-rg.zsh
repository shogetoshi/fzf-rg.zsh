function get_dir() {
    echo ""
}

function get_query() {
    echo ""
}

function get_lbuf() {
    echo "$1"
}

function get_rbuf() {
    echo "$1"
}

function get_search_path_opt() {
    local search_path=$(git rev-parse --show-cdup 2>/dev/null)
    if [[ -n $search_path ]]; then
        echo "--search-path ${search_path}"
    else
        echo ""
    fi
}

function fzf-rg() {
    local dir=$(get_dir "${LBUFFER}" "${RBUFFER}")
    local query=$(get_query "${LBUFFER}")
    local lbuf=$(get_lbuf ${LBUFFER})
    local rbuf=$(get_rbuf ${RBUFFER})
    local out=$(rg -uuu --ignore-file ~/.ignore --color always -n ^ | \
        fzf --ansi --multi --reverse \
        --query "$query" \
        --delimiter ':' \
        --nth '3..' \
        --preview 'bat --plain --number --color always --highlight-line={2} {1}' \
        --preview-window '+{2}-5:down:70%' | \
        awk -F ':' '{print $1}' | \
        awk '!a[$0]++' \
    )
    if [[ -n "$out" ]]; then
        out=$(echo "$out" | sed "s/.*/'&'/" | tr '\n' ' ')
        BUFFER="${lbuf}${out}${rbuf}"
        CURSOR=$((${#lbuf}+${#out}))
    fi
    zle redisplay
}
zle -N fzf-rg
