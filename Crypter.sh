#!/bin/bash

function display_help() {
    echo "Usage: $0"
    echo
    echo "Options:"
    echo "  1  Decrypt Caesar cipher"
    echo "  2  Decrypt Base64"
    echo "  3  Decrypt ROT13"
    echo "  4  Decrypt Vigenère cipher"
    echo "  5  Decrypt Enigma machine"
    echo "  h  Display this help message"
    exit 1
}

function decrypt_caesar() {
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

function decrypt_enigma() {
    local message="$1"
    local rotors=( "EKMFLGDQVZ" "AJDHSZXCNW" "BDFHJLCPRT" )
    local reflector=( "YRUHQSLDPX" )
    local rotor_positions=( 0 0 0 )

    rotate_rotors() {
        rotor_positions[0]=$(( (rotor_positions[0] + 1) % 26 ))
        for i in {0..2}; do
            if [[ ${rotor_positions[i]} -eq 0 && $i -lt 2 ]]; then
                rotor_positions[$((i + 1))]=$(( (rotor_positions[$((i + 1))] + 1) % 26 ))
            fi
        done
    }

    encode_character() {
        local char="$1"
        for i in {0..2}; do
            index=$(( ( $(printf "%d" "'$char") - 65 + rotor_positions[i]) % 26 ))
            char=${rotors[i]:index:1}
            index=$(( ( $(printf "%d" "'$char") - 65 - rotor_positions[i] + 26 ) % 26 ))
            char=$(printf \\$(printf '%03o' $((index + 65))))
        done

        char=${reflector[0]:$(($(printf "%d" "'$char") - 65)):1}

        for i in {2..0}; do
            index=$(( ( $(printf "%d" "'$char") - 65 + rotor_positions[i]) % 26 ))
            for j in {0..25}; do
                if [[ ${rotors[i]:j:1} == "$char" ]]; then
                    index=$(( (j - rotor_positions[i] + 26) % 26 ))
                    char=$(printf \\$(printf '%03o' $((index + 65))))
                    break
                fi
            done
        done

        echo "$char"
    }

    encoded=""
    for (( i=0; i<${#message}; i++ )); do
        char="${message:i:1}"
        if [[ "$char" =~ [A-Z] ]]; then
            rotate_rotors
            encoded+=$(encode_character "$char")
        else
            encoded+="$char"
        fi
    done
    echo "$encoded"
}

echo "Select decryption method:"
echo "1. Decrypt Caesar cipher"
echo "2. Decrypt Base64"
echo "3. Decrypt ROT13"
echo "4. Decrypt Vigenère cipher"
echo "5. Decrypt Enigma machine"
echo "h. Help"
read -p "Enter your choice: " choice

case $choice in
    1)
        read -p "Enter custom key: " key
        read -p "Enter text to decrypt: " text
        result=$(decrypt_caesar "$key" "$text")
        ;;
    2)
        read -p "Enter Base64 encoded text: " text
        result=$(decrypt_base64 "$text")
        ;;
    3)
        read -p "Enter ROT13 text: " text
        result=$(decrypt_rot13 "$text")
        ;;
    4)
        read -p "Enter Vigenère key: " key
        read -p "Enter text to decrypt: " text
        result=$(decrypt_vigenere "$key" "$text")
        ;;
    5)
        read -p "Enter text to decrypt with Enigma: " text
        result=$(decrypt_enigma "$text")
        ;;
    h)
        display_help
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo "Decrypted result: $result"
