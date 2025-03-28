#!/bin/bash
# My attempt to make the SHA256 hashes of two files match for my course

# Config
REAL_BASE=~/Downloads/Confession/confession_real.txt
FAKE_BASE=~/Downloads/Confession/confession_fake.txt
TARGET_MATCH_LENGTH=4  # Match last n hex digits
WORKDIR=~/Downloads/Confession
REAL_TEMP="$WORKDIR/real_temp.txt"
FAKE_TEMP="$WORKDIR/fake_temp.txt"

cd "$WORKDIR" || exit 1

echo "[*] Starting hash suffix match..."
echo "[*] Target: Last $TARGET_MATCH_LENGTH hex digits must match."

try=0
start_time=$(date +%s)

while true; do
    ((try++))

    # Randomly modify line endings for real and fake files with more entropy
    awk -v seed=$RANDOM 'BEGIN { srand(seed) }
    {
        r = rand();
        if (r < 0.33) print $0;
        else if (r < 0.66) print $0" ";
        else print $0"\t";
    }' "$REAL_BASE" > "$REAL_TEMP"

    awk -v seed=$RANDOM 'BEGIN { srand(seed) }
    {
        r = rand();
        if (r < 0.33) print $0;
        else if (r < 0.66) print $0" ";
        else print $0"\t";
    }' "$FAKE_BASE" > "$FAKE_TEMP"

    hash_real=$(sha256sum "$REAL_TEMP" | awk '{print $1}')
    hash_fake=$(sha256sum "$FAKE_TEMP" | awk '{print $1}')

    suffix_real="${hash_real: -$TARGET_MATCH_LENGTH}"
    suffix_fake="${hash_fake: -$TARGET_MATCH_LENGTH}"

    if [[ "$suffix_real" == "$suffix_fake" ]]; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))

        echo "[+] Match found after $try tries in $duration seconds!"
        echo "    Real hash: $hash_real"
        echo "    Fake hash: $hash_fake"

        cp "$REAL_TEMP" "$WORKDIR/matched_real.txt"
        cp "$FAKE_TEMP" "$WORKDIR/matched_fake.txt"
        break
    fi

    if (( try % 500 == 0 )); then
        echo "[*] Try $try... Current: $suffix_real vs $suffix_fake"
    fi
done
