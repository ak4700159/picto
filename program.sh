#!/bin/bash

# -------------------- 사용자 설정 --------------------
MIN_COMMITS=20
MAX_COMMITS=25
MIN_FILES=10
MAX_FILES=20
MIN_LINES=1000
MAX_LINES=2000
# ----------------------------------------------------

# 🔹 랜덤 숫자 생성 함수
rand() {
    local min=$1
    local max=$2
    echo $(( RANDOM % (max - min + 1) + min ))
}

# 🔹 인자로 폴더명을 받음
TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    echo "❌ 사용법: $0 <폴더명>"
    exit 1
fi

# 🔹 Git 저장소 확인
if [ ! -d ".git" ]; then
    echo "❌ 현재 디렉토리는 Git 저장소가 아닙니다."
    exit 1
fi

# 🔹 폴더 없으면 생성
mkdir -p "$TARGET_DIR"

# 🔹 더미 커밋 수 결정
NUM_COMMITS=$(rand $MIN_COMMITS $MAX_COMMITS)

for ((i=1; i<=$NUM_COMMITS; i++)); do
    FILE_COUNT=$(rand $MIN_FILES $MAX_FILES)
    LINE_TOTAL=$(rand $MIN_LINES $MAX_LINES)
    AVG_LINES=$(( LINE_TOTAL / FILE_COUNT ))

    echo "[$i/$NUM_COMMITS] 폴더: $TARGET_DIR, 파일 $FILE_COUNT개, 총 $LINE_TOTAL줄"

    for ((j=1; j<=$FILE_COUNT; j++)); do
        LINES=$(rand $((AVG_LINES/2)) $((AVG_LINES*3/2)))
        FILENAME="${TARGET_DIR}/dummy_${i}_${j}.txt"
        echo "  → 생성: $FILENAME ($LINES줄 삽입)"

        # 1. 라인 삽입
        > "$FILENAME"
        for ((k=1; k<=$LINES; k++)); do
            echo "라인 ${k} - $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)" >> "$FILENAME"
        done

        # 2. 무작위 라인 삭제
        LINES_IN_FILE=$(wc -l < "$FILENAME")
        if (( LINES_IN_FILE > 10 )); then
            DELETE_COUNT=$(rand $((LINES_IN_FILE / 10)) $((LINES_IN_FILE / 3)))
            echo "     → ${DELETE_COUNT}줄 삭제"

            shuf -i 1-"$LINES_IN_FILE" -n "$DELETE_COUNT" | sort -r | while read -r line_num; do
                sed -i "${line_num}d" "$FILENAME"
            done
        fi
    done

    git add "$TARGET_DIR"
    git commit -m "더미 커밋 ${i}: ${FILE_COUNT}개 파일, ${LINE_TOTAL}줄 변경 (일부 삭제 포함)"
done

echo "✅ 총 $NUM_COMMITS개의 더미 커밋 완료 (${TARGET_DIR} 디렉토리 기준)"

