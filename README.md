# whale-reaper

Whale 브라우저의 Helper 프로세스가 CPU를 과도하게 점유할 때 자동으로 강제 종료하는 모니터링 도구입니다.

## 동작 방식

실행 시 `Whale Helper` 프로세스 중 CPU 사용률이 임계값(기본 20%)을 초과하는 프로세스를 찾아 종료합니다.
종료는 SIGTERM → SIGKILL 순서로 시도하며, brew services를 통해 주기적으로 실행됩니다.

## 설치
```sh
brew install greedylabs/tap/whale-reaper
brew services start whale-reaper
```

## 설정

설정 파일 경로:
```
$(brew --prefix)/etc/whale-reaper/config
```

| 항목 | 기본값 | 설명 |
|---|---|---|
| `WHALE_CPU_THRESHOLD` | `20` | 종료 기준 CPU 사용률 (%) |

설정 예시:
```sh
WHALE_CPU_THRESHOLD=30
```

## 로그
```sh
# 일반 로그
tail -f $(brew --prefix)/var/log/whale-reaper/info.log

# 에러 로그
tail -f $(brew --prefix)/var/log/whale-reaper/err.log
```
