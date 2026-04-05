#!/bin/bash
# ============================================================
# Whale Helper 프로세스 CPU 과점유 자동 종료 스크립트
# ============================================================

# Intel: /usr/local, Apple Silicon: /opt/homebrew
if [[ -d "/opt/homebrew" ]]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

# 설정 파일 로드
CONFIG_FILE="${BREW_PREFIX}/etc/whale-reaper/config"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

readonly CPU_THRESHOLD="${WHALE_CPU_THRESHOLD:-20}"

log()     { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $1"; }
log_err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >&2; }

kill_process() {
    local pid="$1" cpu="$2" name="$3"

    /bin/kill -15 "$pid" 2>/dev/null
    sleep 2

    if /bin/kill -0 "$pid" 2>/dev/null; then
        /bin/kill -9 "$pid" 2>/dev/null && \
            log "SIGKILL 강제 종료 | PID: $pid | CPU: ${cpu}% | $name" || \
            log_err "종료 실패 | PID: $pid"
    else
        log "SIGTERM 정상 종료 | PID: $pid | CPU: ${cpu}% | $name"
    fi
}

# ── 프로세스 감지 및 종료 ─────────────────────────────────────
targets=$(
    /bin/ps -axo pid=,pcpu=,comm= \
    | /usr/bin/awk -v t="$CPU_THRESHOLD" '$2+0 > t && /Whale Helper/'
)

if [[ -z "$targets" ]]; then
    log "대상 프로세스 없음"
else
    while IFS=' ' read -r pid cpu name; do
        [[ "$pid" =~ ^[0-9]+$ ]] || { log_err "유효하지 않은 PID: $pid"; continue; }

        log "CPU 임계값 초과 감지 | PID: $pid | CPU: ${cpu}% | $name"
        kill_process "$pid" "$cpu" "$name"
    done <<< "$targets"
fi
