#!/bin/bash
# ============================================================
# whale_helper_monitor.sh
# Whale Helper 프로세스 CPU 과점유 자동 종료 스크립트
# ============================================================

readonly CPU_THRESHOLD=20

log()     { echo "[INFO]  $1"; }
log_err() { echo "[ERROR] $1" >&2; }

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
while IFS=' ' read -r pid cpu name; do
    [[ "$pid" =~ ^[0-9]+$ ]] || { log_err "유효하지 않은 PID: $pid"; continue; }

    log "CPU 임계값 초과 감지 | PID: $pid | CPU: ${cpu}% | $name"
    kill_process "$pid" "$cpu" "$name"
done < <(
    /bin/ps -axo pid=,pcpu=,comm= \
    | /usr/bin/awk -v t="$CPU_THRESHOLD" '$2+0 > t && /Whale Helper/'
)
