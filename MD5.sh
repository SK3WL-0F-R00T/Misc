#!/bin/bash
REAL_BASE="/Users/levi.green/Downloads/ZZEN9203_Exam_25H2/AliceForPresident.pdf"
FAKE_BASE="/Users/levi.green/Downloads/ZZEN9203_Exam_25H2/BobForPresident.pdf"
WORKDIR="/Users/levi.green/Downloads/ZZEN9203_Exam_25H2"
REAL_TEMP="$WORKDIR/Alice_temp.pdf"
FAKE_TEMP="$WORKDIR/Bob_temp.pdf"
TARGET_MATCH_LENGTH=2  # Compare first or last 2 hex digits

cd "$WORKDIR" || exit 1

echo "[*] Starting MD5 prefix/suffix match..."
echo "[*] Goal: First or last $TARGET_MATCH_LENGTH hex digits must match."

try=0
start_time=$(date +%s)

while true; do
    ((try++))

    cp "$REAL_BASE" "$REAL_TEMP"
    cp "$FAKE_BASE" "$FAKE_TEMP"

    # Append 1–10 newline characters to each file
    printf '\n%.0s' $(seq 1 $((RANDOM % 10 + 1))) >> "$REAL_TEMP"
    printf '\n%.0s' $(seq 1 $((RANDOM % 10 + 1))) >> "$FAKE_TEMP"

    # Calculate MD5 hashes
    hash_real=$(md5 -q "$REAL_TEMP")
    hash_fake=$(md5 -q "$FAKE_TEMP")

    prefix_real="${hash_real:0:$TARGET_MATCH_LENGTH}"
    prefix_fake="${hash_fake:0:$TARGET_MATCH_LENGTH}"

    suffix_real="${hash_real: -$TARGET_MATCH_LENGTH}"
    suffix_fake="${hash_fake: -$TARGET_MATCH_LENGTH}"

    if [[ "$prefix_real" == "$prefix_fake" || "$suffix_real" == "$suffix_fake" ]]; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))

        echo "[+] Match found after $try tries in $duration seconds!"
        echo "    Real hash: $hash_real"
        echo "    Fake hash: $hash_fake"

        mv "$REAL_TEMP" "$WORKDIR/AliceForPresident.pdf"
        mv "$FAKE_TEMP" "$WORKDIR/BobForPresident.pdf"
        break
    fi

    if (( try % 200 == 0 )); then
        echo "[*] Try $try... Prefix: $prefix_real vs $prefix_fake | Suffix: $suffix_real vs $suffix_fake"
    fi
done
