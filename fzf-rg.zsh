function get_dir() {
    local lbuf="$1"
    # LBUFFERの最後がスペースなら無関係なので空を返す
    if [[ "$lbuf" == *" " ]]; then
        echo ""
        return
    fi
    # 最後の単語を取得
    local last_word="${lbuf##* }"
    # スラッシュがなければ空を返す
    if [[ "$last_word" != *"/"* ]]; then
        echo ""
        return
    fi
    # ディレクトリ部分を取得（最後のスラッシュより前）
    local dir="${last_word%/*}"
    # ~をホームディレクトリに展開
    dir="${dir/#\~/$HOME}"
    # 環境変数を展開
    dir="${(e)dir}"
    echo "$dir"
}

function get_query() {
    local lbuf="$1"
    # LBUFFERの最後がスペースなら無関係なので空を返す
    if [[ "$lbuf" == *" " ]]; then
        echo ""
        return
    fi
    # 最後の単語を取得
    local last_word="${lbuf##* }"
    # 最後の/以降を取得（/がなければ全体を返す）
    echo "${last_word##*/}"
}

function get_lbuf() {
    local lbuf="$1"
    # 最後の単語を取得（スペース区切りで最後の部分）
    local last_word="${lbuf##* }"
    # 最後の単語を除いた部分を返す
    echo "${lbuf%${last_word}}"
}

function get_rbuf() {
    echo "${1## }"
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
    local out=$(rg -uuu --ignore-file ~/.ignore --color always -n ^ ${dir} 2>/dev/null | \
        fzf --ansi --multi --reverse --wrap \
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
