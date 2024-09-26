#!/bin/bash

function display_help() {
    echo "Usage: $0 [-c | -C <key> | -b | -r | -v <key> | -e | -h] <text>"
    echo
    echo "Options:"
    echo "  -c             Decrypt Caesar cipher using key 3"
    echo "  -C <key>      Decrypt Caesar cipher using custom key"
    echo "  -b             Decrypt Base64"
    echo "  -r             Decrypt ROT13"
    echo "  -v <key>      Decrypt Vigenère cipher"
    echo "  -e             Decrypt Enigma cipher (placeholder)"
    echo "  -h             Display this help message"
    exit 1
}


function decrypt_caesar() {
    echo "$1" | tr 'A-Za-z' 'X-ZA-Wx-zay'  
}


function decrypt_caesar_custom() {
    local key=$1
    echo "$2" | tr "$(echo {A..Z})" "$(echo {A..Z} | cut -c$((26-key+1))-26)$(echo {A..Z} | cut -c1-$((26-key)))" | tr "$(echo {a..z})" "$(echo {a..z} | cut -c$((26-key+1))-26)$(echo {a..z} | cut -c1-$((26-key)))"
}


function decrypt_base64() {
    echo "$1" | base64 --decode
}


function decrypt_rot13() {
    echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}


function decrypt_vigenere() {
    local key=$1
    local text=$2
    local key_len=${#key}
    local decrypted=""
    for ((i = 0; i < ${#text}; i++)); do
        char=${text:i:1}
        if [[ $char =~ [A-Za-z] ]]; then
            ascii_offset=$(if [[ $char =~ [A-Z] ]]; then echo 65; else echo 97; fi)
            key_char=${key:$((i % key_len)):1}
            key_offset=$(( $(printf "%d" "'$key_char") - 65 ))
            decrypted+=$(printf "\\$(printf '%03o' $(( (($(printf "%d" "'$char") - $ascii_offset - key_offset + 26) % 26) + ascii_offset )) )")
        else
            decrypted+="$char"
        fi
    done
    echo "$decrypted"
}


if [[ $# -lt 2 ]]; then
    display_help
fi


while getopts ":cC:b:r:v:e:h" opt; do
    case $opt in
        c)
            decrypt_caesar "$2"
            exit 0
            ;;
        C)
            key=$OPTARG
            decrypt_caesar_custom "$key" "$2"
            exit 0
            ;;
        b)
            decrypt_base64 "$2"
            exit 0
            ;;
        r)
            decrypt_rot13 "$2"
            exit 0
            ;;
        v)
            key=$OPTARG
            decrypt_vigenere "$key" "$2"
            exit 0
            ;;
        e)
            echo "Enigma cipher decryption is not implemented."
            exit 0
            ;;
        h)
            display_help
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            display_help
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            display_help
            ;;
    esac
done


display_help
