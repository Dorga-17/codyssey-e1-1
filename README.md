# Codyssey E1-1 — 개발 환경 구축

경남 코디세이 E1-1 미션에서 구축한 Linux·Docker 개발 환경과 실습 결과를 정리한 저장소입니다.

Windows에서 WSL2와 Ubuntu를 구성하고, Docker로 Nginx 웹서버를 실행했습니다. Docker Compose로 두 개의 웹서버를 관리하고 Git·GitHub로 결과물과 증빙 자료를 보관했습니다.

> **문서 기준**: 실습 당시 확인한 결과를 기록했습니다. 현재 실행 상태는 컨테이너 재시작이나 설정 변경에 따라 달라질 수 있습니다. 명령어와 화면 증빙은 항목별로 연결했습니다.

## 1. 개발 환경

| 항목 | 사용 환경 |
|---|---|
| 호스트 운영체제 | Windows |
| Linux 실행 환경 | WSL2, Ubuntu 26.04.1 LTS |
| WSL 커널 | `6.18.54.1-microsoft-standard-WSL2` |
| Docker | Docker Desktop / Docker Engine 29.9.2 |
| Docker Compose | v5.6.1 |
| Git | 2.53.0 |
| 편집기 | Visual Studio Code (WSL 연결) |
| 웹서버 | Nginx (`nginx:alpine` 기반) |

### Linux 및 Docker 환경 확인

Ubuntu 터미널에서 배포판·커널·사용자 정보를 확인했습니다.

```bash
cat /etc/os-release
uname -s
uname -r
uname -m
whoami
```

주요 확인 결과는 다음과 같습니다.

```text
Ubuntu 26.04.1 LTS
Linux
6.18.54.1-microsoft-standard-WSL2
x86_64
yubin
```

Docker Desktop과 Ubuntu WSL을 연동한 뒤 다음 명령어로 Docker 엔진 연결을 확인했습니다.

```bash
docker version
docker info
```

두 명령어에서 Docker **Client와 Server 정보가 모두 조회**되어 Ubuntu의 Docker CLI가 Docker Desktop의 엔진에 연결되어 있음을 확인했습니다.

**증빙 자료**

- [WSL 환경 확인](evidence/1.%20wsl-version.png)
- [Ubuntu 배포판 확인](evidence/3.%20ubuntu-release.png)
- [Docker Desktop 실행 화면](evidence/12.%20docker-desktop.png)
- [Docker 환경 확인 1](evidence/13.%20docker-environment%20%281%29.png)
- [Docker 환경 확인 2](evidence/13.%20docker-environment%20%282%29.png)
- [Docker 환경 확인 3](evidence/13.%20docker-environment%20%283%29.png)
- [Docker 환경 확인 4](evidence/13.%20docker-environment%20%284%29.png)

## 2. 프로젝트 구조

```text
workstation/
├── .gitignore
├── .env.example
├── Dockerfile
├── README.md
├── compose.yaml
├── site/
│   └── index.html
├── linux-practice/
│   └── hello.txt
└── evidence/
    └── 실습 증빙 이미지(.png)
```

| 경로 | 역할 |
|---|---|
| `Dockerfile` | Nginx 기반 커스텀 이미지 빌드 설정 |
| `compose.yaml` | `web`, `web2` 서비스 및 포트 매핑 정의 |
| `.env.example` | Compose 포트 환경 변수의 예시 값 |
| `.gitignore` | `.env` 등 Git에서 제외할 항목 설정 |
| `site/index.html` | Nginx가 제공하는 정적 HTML 페이지 |
| `linux-practice/hello.txt` | Linux 파일 작업·권한 변경 실습 파일 |
| `evidence/` | 명령어 실행 결과와 브라우저 화면의 증빙 이미지 |
| `README.md` | 실습 과정, 검증 결과 및 재현 방법 |

실제 포트 값은 로컬 `.env`에 저장하며 Git에 포함하지 않습니다. `.git/`은 Git이 관리하는 내부 디렉터리이므로 프로젝트 파일 목록과 별도로 취급합니다.

## 3. Linux 개발 환경 및 기본 명령어

### 파일 및 디렉터리 작업

프로젝트 작업 경로는 다음과 같습니다.

```bash
pwd
```

```text
/home/yubin/codyssey/workstation
```

Ubuntu 터미널에서 다음 명령어로 파일과 디렉터리를 관리했습니다.

| 명령어 | 실습에서 확인한 기능 |
|---|---|
| `pwd` | 현재 작업 위치 확인 |
| `ls`, `ls -la` | 파일과 디렉터리 조회 |
| `mkdir` | 디렉터리 생성 |
| `touch` | 빈 파일 생성 |
| `echo`, `cat` | 파일에 내용 작성 및 내용 조회 |
| `cp` | 파일 복사 |
| `mv` | 파일 이동 또는 이름 변경 |
| `rm` | 실습용 파일 삭제 |

`linux-practice/hello.txt`를 만들고 파일 작업을 수행한 결과는 증빙 이미지에 기록했습니다.

**증빙 자료**

- [Linux 파일 및 디렉터리 작업](evidence/6.%20linux-file-operations.png)
- [Linux 파일 삭제](evidence/7.%20linux-file-deletion.png)

### 파일 및 디렉터리 권한

Linux 권한은 **소유자(User)·그룹(Group)·기타 사용자(Others)** 순서로 표현합니다. 읽기(`r`)는 4, 쓰기(`w`)는 2, 실행(`x`)은 1이며 권한별 숫자를 더해 설정합니다.

| 숫자 | 권한 | 의미 |
|---|---|---|
| 4 | `r--` | 읽기 |
| 2 | `-w-` | 쓰기 |
| 1 | `--x` | 실행 또는 디렉터리 탐색 |
| 7 | `rwx` | 읽기 + 쓰기 + 실행 |
| 6 | `rw-` | 읽기 + 쓰기 |
| 5 | `r-x` | 읽기 + 실행 |
| 0 | `---` | 해당 권한 없음 |

이번 실습의 권한 설정을 **프로젝트 루트에서 실행할 수 있는 형태**로 적으면 다음과 같습니다.

| 대상 | 명령어 | 확인 시 권한 표현 |
|---|---|---|
| 파일 | `chmod 600 linux-practice/hello.txt` | `-rw-------` |
| 파일 | `chmod 644 linux-practice/hello.txt` | `-rw-r--r--` |
| 디렉터리 | `chmod 700 linux-practice` | `drwx------` |
| 디렉터리 | `chmod 755 linux-practice` | `drwxr-xr-x` |

```bash
ls -l linux-practice/hello.txt
ls -ld linux-practice
```

`ls -l`에서 첫 문자는 파일 종류(`-`: 일반 파일, `d`: 디렉터리)를, 이후 아홉 문자는 사용자별 권한을 나타냅니다. 위 권한 표현은 각 설정에 대응하는 값이며 실제 터미널 출력은 아래 이미지에서 확인할 수 있습니다.

일반 파일에서 `x`는 실행 권한이고, 디렉터리에서 `x`는 내부 경로에 접근할 수 있는 탐색 권한입니다. 디렉터리 항목 생성·삭제에는 `w` 외에 `x` 등의 권한도 필요합니다.

**증빙 자료**

- [파일 권한 600](evidence/8.%20chmod-600.png)
- [파일 권한 644](evidence/9.%20chmod-644.png)
- [디렉터리 권한 700](evidence/10.%20directory-chmod-700.png)
- [디렉터리 권한 755](evidence/11.%20directory-chmod-755.png)

### 절대경로와 상대경로

| 구분 | 기준 | 프로젝트 예시 |
|---|---|---|
| 절대경로 | 파일 시스템의 `/`부터 시작 | `/home/yubin/codyssey/workstation` |
| 절대경로 | 컨테이너 내부의 고정 위치 | `/usr/share/nginx/html/` |
| 상대경로 | 현재 위치 또는 지정된 기준 경로 | `site/index.html`, `./site` |

절대경로는 현재 작업 위치와 관계없이 같은 위치를 지정합니다. 상대경로는 기준 위치에 따라 해석되므로 프로젝트 내부 파일을 다룰 때 편리합니다.

Dockerfile의 다음 명령어에서도 두 방식을 함께 사용했습니다.

```dockerfile
COPY site/ /usr/share/nginx/html/
```

- `site/`: **빌드 컨텍스트**를 기준으로 해석하는 상대경로
- `/usr/share/nginx/html/`: 이미지 내부 파일 시스템의 절대경로

## 4. Docker 이미지 및 컨테이너

### Hello World 실행

```bash
docker run --name codyssey-hello hello-world
docker logs codyssey-hello
```

출력에서 다음 메시지를 확인했습니다.

```text
Hello from Docker!
```

`codyssey-hello`는 메시지를 출력한 뒤 `Exited (0)`으로 종료되었습니다. 이는 프로그램이 정상 종료되었음을 뜻합니다.

**증빙 자료**

- [Hello World 실행](evidence/15.%20docker-hello-world.png)
- [Hello World 로그](evidence/16.%20docker-container-logs.png)

### 컨테이너 접속 방식 비교

Ubuntu 컨테이너에서 `docker exec`와 `docker attach`를 비교했습니다.

| 명령어 | 실습 결과 |
|---|---|
| `docker exec` | 별도로 실행한 Bash 셸을 종료해도 컨테이너의 주 프로세스는 유지됨 |
| `docker attach` | 컨테이너의 주 Bash 프로세스를 종료하자 컨테이너도 종료됨 |

`attach`가 항상 컨테이너를 종료시키는 것은 아닙니다. **이번 실습에서는 연결한 주 프로세스를 종료했기 때문에** 컨테이너가 종료된 것입니다.

**증빙 자료**

- [exec 접속 후 컨테이너 유지](evidence/60.%20docker%20exec%20persistence.png)
- [attach 접속 후 컨테이너 종료](evidence/61.%20docker%20attach%20exit.png)

### 이미지와 컨테이너 목록

```bash
docker images
docker ps -a
```

조회 당시 이미지 4개가 확인되었습니다.

| 이미지 | 용도 |
|---|---|
| `hello-world:latest` | Docker 실행 테스트 |
| `ubuntu:24.04` | Linux 컨테이너 실습 |
| `nginx:alpine` | 웹서버 기반 이미지 및 바인드 마운트 실습 |
| `codyssey-web:1.0` | 직접 제작한 웹서버 이미지 |

`docker ps -a` 조회 당시 컨테이너는 10개였고, Compose 컨테이너 2개는 `Up`, 나머지 8개는 `Exited` 상태였습니다.

| 구분 | 이미지(Image) | 컨테이너(Container) |
|---|---|---|
| 역할 | 파일 시스템과 실행 설정을 담은 템플릿 | 이미지를 기반으로 생성한 개별 인스턴스 |
| 확인 명령어 | `docker images` | `docker ps -a` |
| 상태 | 로컬에 저장됨 | `Up`, `Exited` 등 실행 상태가 있음 |
| 관계 | 하나의 이미지로 여러 컨테이너 생성 가능 | 컨테이너별 이름·포트·상태를 따로 관리 |

실제로 `codyssey-web:1.0` 이미지 하나를 바탕으로 단독 웹서버 컨테이너와 Compose의 `workstation-web-1`, `workstation-web2-1`을 실행했습니다.

**증빙 자료**

- [Docker 이미지 목록](evidence/95.%20docker%20images.png)
- [전체 컨테이너 목록](evidence/96.%20docker%20ps%20-a.png)
- [여러 웹서버 컨테이너](evidence/28.%20docker%20multiple%20containers.png)

## 5. Dockerfile 기반 커스텀 이미지

`nginx:alpine`을 기반으로 정적 HTML 파일을 포함하는 `codyssey-web:1.0` 이미지를 만들었습니다.

**Dockerfile**

```dockerfile
FROM nginx:alpine

LABEL description="Codyssey workstation web server"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```

- `FROM`: 기반 이미지 지정
- `LABEL`: 이미지 설명 정보 추가
- `COPY`: 빌드 컨텍스트의 `site/`를 이미지 내부 웹 콘텐츠 디렉터리로 복사
- `EXPOSE 80`: 컨테이너가 사용하는 웹서버 포트를 문서화 (호스트 포트 게시 기능은 아님)

**빌드 명령어**

```bash
docker build -t codyssey-web:1.0 .
```

- `-t`: 이미지 이름과 태그를 `codyssey-web:1.0`으로 지정
- `.`: 현재 디렉터리를 빌드 컨텍스트로 사용

빌드 후 `docker images`에서 다음 항목을 확인했습니다.

```text
REPOSITORY      TAG   IMAGE ID       SIZE
codyssey-web    1.0   1e55f0130c0c   93.6MB
```

이는 이미지가 로컬에 저장되어 있음을 보여줍니다. 빌드 과정의 상세 결과는 빌드 로그 이미지에 남겼습니다. 해당 이미지로 컨테이너를 실행해 브라우저에 **Hello, Codyssey!** 페이지가 표시되는 것도 확인했습니다.

`COPY`로 이미지에 포함한 HTML은 호스트 파일 수정만으로 자동 변경되지 않습니다. 변경된 파일을 이미지에 반영하려면 다시 빌드해야 하며, 호스트 수정 내용을 즉시 반영하려면 다음 절의 바인드 마운트를 사용할 수 있습니다.

**증빙 자료**

- [Dockerfile 내용](evidence/23.%20dockerfile%20source.png)
- [이미지 빌드 결과](evidence/25.%20docker%20build.png)
- [웹서버 컨테이너 실행](evidence/26.%20docker%20web-container.png)
- [웹페이지 접속](evidence/27.%20docker%20browser.png)
- [이미지 목록](evidence/95.%20docker%20images.png)

## 6. 포트 매핑, 바인드 마운트, Docker 볼륨

### 포트 매핑과 HTTP 응답

호스트 포트와 Nginx 컨테이너 내부의 80번 포트를 연결했습니다.

| 실행 방식 | 호스트 포트 | 컨테이너 포트 | 확인 주소 |
|---|---|---|---|
| 단독 웹서버 | 8080 | 80 | `http://localhost:8080` |
| 두 번째 단독 웹서버 | 8081 | 80 | `http://localhost:8081` |
| 바인드 마운트 웹서버 | 8082 | 80 | `http://localhost:8082` |
| Compose `web` | 8083 | 80 | `http://localhost:8083` |
| Compose `web2` | 8085 | 80 | `http://localhost:8085` |

Compose 실습 중 `web2`의 호스트 포트를 8084에서 8085로 변경했습니다. **최종 설정은 8083·8085**입니다.

웹서버 로그는 다음 명령어로 확인했습니다.

```bash
docker compose logs --tail 10
```

기본 페이지 요청의 실제 로그에 다음 내용이 포함되어 있었습니다.

```text
GET /?utm_source=chatgpt.com HTTP/1.1" 200 673
```

- `GET`: 웹페이지 요청
- `200`: 요청이 성공적으로 처리됨을 나타내는 HTTP 상태 코드
- `673`: 해당 로그에 기록된 응답 본문 크기(바이트)

브라우저에서도 HTML 페이지가 표시되는 것을 확인했습니다. **HTTP 200은 로그로, 화면에 나타난 HTML 콘텐츠는 브라우저 증빙으로 각각 확인**했습니다.

Docker는 컨테이너마다 네트워크 네임스페이스를 분리하므로, 서로 다른 컨테이너가 각각 내부 80번 포트를 사용할 수 있습니다. 두 Compose 서비스는 `workstation_default` 네트워크에 연결되며, 호스트 포트를 다르게 게시해 외부에서 구분해 접속합니다.

**증빙 자료**

- [Docker 포트 매핑](evidence/29.%20docker%20port%20mapping.png)
- [Compose 멀티 컨테이너 접속](evidence/71.%20compose%20multicontainer%20browser.png)
- [HTTP 응답 로그](evidence/73.%20compose%20logs.png)
- [최종 포트 웹페이지 접속](evidence/83.%20compose%20env%20browser.png)

### 바인드 마운트: 호스트 HTML 변경 반영

호스트의 `site/`를 컨테이너의 `/usr/share/nginx/html/`에 **읽기 전용**으로 연결했습니다. 같은 구성을 재현하는 명령어는 다음과 같습니다.

```bash
docker run -d \
  --name codyssey-web-bind \
  -p 8082:80 \
  --mount "type=bind,source=$(pwd)/site,target=/usr/share/nginx/html,readonly" \
  nginx:alpine
```

프로젝트 루트에서 실행하면 `$(pwd)/site`가 호스트의 `site/` 경로를 가리킵니다. `readonly`는 컨테이너에서 해당 마운트 경로를 수정하지 못하도록 하는 옵션입니다. 이미 같은 이름의 컨테이너가 있다면 재생성할 필요는 없습니다.

`site/index.html`을 수정한 후 바인드 마운트 컨테이너의 웹페이지에 변경 내용이 반영되는 것을 확인했습니다. 이 변경은 **바인드 마운트된 파일의 반영**이며, 기존에 빌드한 Docker 이미지 자체가 변경된 것은 아닙니다.

**증빙 자료**

- [바인드 마운트 변경 전](evidence/32.%20docker%20bind%20before.png)
- [바인드 마운트 변경 전 HTML](evidence/98.%20bind%20html%20before.png)
- [바인드 마운트 변경 후](evidence/33.%20docker%20bind%20after.png)
- [바인드 마운트 변경 후 HTML](evidence/97.%20bind%20html%20after.png)
- [마운트 설정 확인](evidence/34.%20docker%20bind%20inspect.png)

### Docker 볼륨: 컨테이너 삭제 후 데이터 유지

이름이 `codyssey-data`인 Docker 볼륨을 생성하고 Ubuntu 컨테이너의 `/data`에 연결했습니다.

**1. 볼륨 생성**

```bash
docker volume create codyssey-data
```

```text
codyssey-data
```

**2. 최초 컨테이너에서 파일 저장**

```bash
docker run -it --name codyssey-volume-test -v codyssey-data:/data ubuntu:24.04 bash
```

컨테이너 내부에서 실행한 명령어와 확인한 파일 내용입니다.

```bash
echo "Codyssey Volume Persistence Test" > /data/volume-test.txt
cat /data/volume-test.txt
```

```text
Codyssey Volume Persistence Test
```

**3. 기존 컨테이너 삭제 후 같은 볼륨 재사용**

최초 컨테이너에서 `exit`로 나온 후 컨테이너를 삭제하고, 같은 볼륨을 새 컨테이너에 연결했습니다.

```bash
docker rm codyssey-volume-test
docker run -it --name codyssey-volume-verify -v codyssey-data:/data ubuntu:24.04 bash
```

새 컨테이너 내부에서 파일을 읽었습니다.

```bash
cat /data/volume-test.txt
```

```text
Codyssey Volume Persistence Test
```

파일 내용이 그대로 남아 있어 **컨테이너를 삭제해도 별도로 관리되는 볼륨의 데이터는 유지**된다는 사실을 확인했습니다.

**4. 볼륨 정보 확인**

```bash
docker volume inspect codyssey-data
```

볼륨 이름은 `codyssey-data`, 드라이버는 `local`이었으며 Docker 엔진이 관리하는 저장 경로는 다음과 같이 표시되었습니다.

```text
/var/lib/docker/volumes/codyssey-data/_data
```

이 경로는 **Docker 엔진 내부 저장 위치**이고, 컨테이너에서 파일을 사용하는 경로는 `/data`입니다.

**증빙 자료**

- [볼륨 생성](evidence/35.%20docker%20volume%20create.png)
- [볼륨에 파일 저장](evidence/36.%20docker%20volume%20write.png)
- [컨테이너 교체 후 데이터 유지](evidence/37.%20docker%20volume%20persistence.png)
- [볼륨 상세 정보](evidence/38.%20docker%20volume%20inspect.png)

### 바인드 마운트와 볼륨 비교

| 항목 | 바인드 마운트 | Docker 볼륨 |
|---|---|---|
| 저장 위치 | 지정한 호스트 경로 | Docker가 관리하는 저장 공간 |
| 변경 반영 | 호스트 파일 수정이 마운트된 컨테이너에 직접 반영 | 일반적인 호스트 작업 폴더와 자동 동기화되지 않음 |
| 영속성 | 호스트 파일을 유지하면 컨테이너 삭제 후에도 남음 | 볼륨을 삭제하지 않으면 컨테이너 삭제 후에도 남음 |
| 장점 | 개발 중 소스·설정 파일 수정이 편리 | 컨테이너 수명과 데이터 저장을 분리하기 편리 |
| 주의점 | 호스트 경로 의존성, 소유권·권한 문제 | 파일 직접 편집이 불편할 수 있고 내부 파일 권한 확인 필요 |
| 이번 실습 | `site/` 수정 내용을 웹페이지에 반영 | `volume-test.txt`의 영속성 확인 |

따라서 **호스트 파일을 직접 편집하며 개발할 때는 바인드 마운트**, **컨테이너를 교체해도 데이터를 보관해야 할 때는 Docker 볼륨**이 적합합니다.

## 7. Docker Compose

`compose.yaml`로 Nginx 웹서버 서비스 두 개를 구성했습니다.

**compose.yaml**

```yaml
services:
  web:
    image: codyssey-web:1.0
    ports:
      - "${WEB_PORT}:80"

  web2:
    image: codyssey-web:1.0
    ports:
      - "${WEB2_PORT}:80"
```

**.env.example**

```dotenv
WEB_PORT=8083
WEB2_PORT=8085
```

### 재현 방법

Docker Desktop이 실행되고 WSL 연동이 완료된 상태에서 **프로젝트 루트 디렉터리**에서 진행합니다.

```bash
# 커스텀 웹서버 이미지 준비
docker build -t codyssey-web:1.0 .

# .env가 없는 최초 실행 시에만 예시 파일 복사
cp .env.example .env

# 설정 확인 → 서비스 실행 → 상태 확인
docker compose config
docker compose up -d
docker compose ps
```

> 이미 `.env`가 있다면 `cp`를 다시 실행하지 마세요. 기존 포트 설정을 덮어쓸 수 있습니다.

| 서비스 | 이미지 | 호스트:컨테이너 포트 | 접속 주소 |
|---|---|---|---|
| `web` | `codyssey-web:1.0` | `8083:80` | `http://localhost:8083` |
| `web2` | `codyssey-web:1.0` | `8085:80` | `http://localhost:8085` |

`docker compose config`로 환경 변수가 반영된 설정을 확인하고, `docker compose ps`에서 `workstation-web-1`과 `workstation-web2-1`의 `Up` 상태를 확인했습니다. 브라우저에서도 두 포트의 웹페이지가 표시되었습니다.

### 컨테이너 운영 명령어

| 명령어 | 역할 |
|---|---|
| `docker compose logs` | 서비스 로그 조회 |
| `docker compose stop` | 컨테이너 중지(삭제하지 않음) |
| `docker compose start` | 중지된 서비스 컨테이너 시작 |
| `docker compose down` | Compose 컨테이너와 기본 네트워크 정리 |
| `docker compose up -d` | 설정에 따라 서비스 생성·시작 |

**마운트 구성 구분:** 현재 `compose.yaml`에는 `volumes:` 또는 바인드 마운트 설정이 없습니다. 앞 절의 바인드 마운트와 `codyssey-data` 실습은 **Docker CLI로 별도로 실행**한 작업입니다.

**증빙 자료**

- [Compose 서비스 설정](evidence/63.%20docker%20compose%20yaml.png)
- [환경 변수가 적용된 Compose 설정](evidence/79.%20.env%20compose%20yaml.png)
- [Compose 설정 검증](evidence/80.%20compose%20env%20config.png)
- [Compose 컨테이너 상태](evidence/82.%20compose%20env%20ps.png)
- [두 웹페이지 접속](evidence/83.%20compose%20env%20browser.png)
- [Compose 종료 실습](evidence/76.%20compose%20down.png)

## 8. Git 및 GitHub

Git 사용자 정보를 설정하고 기본 브랜치를 `main`으로 지정했습니다. SSH 키를 GitHub에 등록한 뒤 원격 저장소를 SSH 방식으로 연결했습니다.

**설정 확인**

```bash
git config --global user.name
git config --global init.defaultBranch
git branch --show-current
```

확인한 값은 Git 사용자 이름 `Dorga-17`, 기본 브랜치 `main`, 현재 브랜치 `main`입니다. 개인 이메일 주소는 README에 기록하지 않았습니다.

**SSH 인증 확인**

```bash
ssh -T git@github.com
```

```text
Hi Dorga-17! You've successfully authenticated, but GitHub does not provide shell access.
```

**원격 저장소 연결 확인**

```bash
git remote -v
```

```text
origin  git@github.com:Dorga-17/codyssey-e1-1.git (fetch)
origin  git@github.com:Dorga-17/codyssey-e1-1.git (push)
```

`fetch`와 `push`가 모두 같은 SSH 주소를 사용합니다. 프로젝트 파일을 `main` 브랜치에서 버전 관리하고 GitHub 원격 저장소에 업로드했습니다.

**증빙 자료**

- [Git 기본 브랜치 설정](evidence/56.%20git%20default%20branch.png)
- [Git 설정 확인](evidence/57.%20git%20config%20list.png)
- [GitHub SSH 인증](evidence/89.%20github%20ssh%20authentication.png)
- [GitHub SSH 원격 연결](evidence/90.%20github%20ssh%20remote.png)

## 9. 트러블슈팅

### 사례 1. Docker Compose 설정 파일 오류

**현상**

```bash
docker compose config
```

```text
empty compose file
```

Compose가 해당 시점에 유효한 서비스 구성을 읽지 못했습니다. 파일 내용이 없었거나 저장되지 않았을 가능성 때문일 것이라고 판단하였습니다.

**확인 및 조치**

`compose.yaml`에 `web` 서비스 설정을 저장한 후 `docker compose config`를 다시 실행했습니다. 재검증에서 `web` 서비스, `codyssey-web:1.0` 이미지, 호스트 8083번과 컨테이너 80번의 매핑 정보가 출력되었습니다.

이어서 다음 명령어로 서비스를 실행했습니다.

```bash
docker compose up -d
docker compose ps
```

실행 로그에 다음 내용이 표시되었습니다.

```text
Network workstation_default Created
Container workstation-web-1 Started
```

`docker compose ps`에서도 컨테이너가 `Up` 상태이고 `8083:80` 포트 매핑이 적용된 것을 확인했습니다.

**결과**: 초기 설정 읽기 오류의 원인은 파일이 저장되지 않았기 때문이었고, 파일을 저장한 뒤 설정 해석과 컨테이너 실행이 정상적으로 완료되었습니다.

**증빙 자료**

- [Compose 설정 파일](evidence/63.%20docker%20compose%20yaml.png)
- [Compose 설정 확인](evidence/64.%20docker%20compose%20config.png)
- [Compose 컨테이너 실행](evidence/65.%20docker%20compose%20up%20-d.png)
- [Compose 실행 상태](evidence/66.%20docker%20compose%20ps.png)

### 사례 2. Nginx의 `favicon.ico` 요청 오류

**현상**

`docker compose logs --tail 10`에서 다음 오류를 확인했습니다.

```text
open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory)
GET /favicon.ico HTTP/1.1" 404
```

Nginx가 사이트 아이콘 파일을 찾지 못해 해당 요청에 HTTP `404 Not Found`를 반환한 것입니다.

**정상 동작과 비교**

같은 로그에 다음 기본 웹페이지 요청이 기록되어 있었습니다.

```text
GET /?utm_source=chatgpt.com HTTP/1.1" 200 673
```

기본 웹페이지는 HTTP `200`으로 응답했고, 브라우저에서도 HTML 페이지가 표시되었습니다. 따라서 **확인된 404 오류는 사이트 아이콘 요청에 해당하며, HTML 페이지 제공 기능의 실패를 뜻하지 않습니다**.

**결과**: 이번 미션에서는 `favicon.ico`를 추가하지 않았습니다. 사이트 아이콘의 404 오류는 남아 있지만 웹페이지 제공은 정상적으로 확인했습니다.

**증빙 자료**

- [Nginx 로그](evidence/73.%20compose%20logs.png)
- [웹페이지 접속 화면](evidence/71.%20compose%20multicontainer%20browser.png)

### 참고: 호스트 포트 충돌이 발생할 경우

다음은 **실제 발생한 장애가 아니라**, 이번 실습의 포트 매핑을 기준으로 정리한 점검 절차입니다.

1. `port is already allocated` 또는 `bind: address already in use` 등의 오류가 있는지 확인합니다.
2. `docker ps --format "table {{.Names}}\t{{.Ports}}"`로 실행 중인 Docker 컨테이너의 포트를 확인합니다.
3. Ubuntu에서는 `ss -ltnp`로 리스닝 포트를 조사합니다. 다만 WSL2·Docker Desktop 환경에서 Windows 쪽 포트 점유는 이 명령어에 모두 나타나지 않을 수 있습니다.
4. 필요하면 Windows PowerShell에서 `Get-NetTCPConnection -LocalPort 8083 -State Listen`으로 확인하고, 출력된 PID를 `Get-Process -Id <PID>`로 조회합니다.
5. 충돌 원인을 확인한 뒤 해당 서비스를 중지하거나 `.env`의 `WEB_PORT`·`WEB2_PORT`를 사용하지 않는 포트로 변경합니다.
6. `docker compose config`, `docker compose up -d`, `docker compose ps`와 브라우저 접속으로 결과를 확인합니다.

다른 프로그램이 사용 중인 포트를 임의로 해제하거나 해당 프로세스를 종료하지 않도록 주의합니다.

**관련 증빙(포트 매핑 설정 확인용)**

- [Compose 포트 상태](evidence/82.%20compose%20env%20ps.png)
- [포트별 웹페이지 접속](evidence/83.%20compose%20env%20browser.png)

## 10. 실습 증빙 자료

실습 이미지 파일은 [`evidence/`](evidence/) 디렉터리에 보관했습니다. 각 항목의 **증빙 자료**에서 해당 작업의 실행 화면을 직접 확인할 수 있습니다.

### Linux 환경 및 파일 권한

- [Ubuntu 배포판 확인](evidence/3.%20ubuntu-release.png)
- [파일 권한 600 적용](evidence/8.%20chmod-600.png)

### Docker 실행과 이미지

- [Hello World 실행](evidence/15.%20docker-hello-world.png)
- [Docker 이미지 목록](evidence/95.%20docker%20images.png)
- [Docker 컨테이너 목록](evidence/96.%20docker%20ps%20-a.png)

### 웹서버와 데이터 마운트

- [Docker 이미지 빌드](evidence/25.%20docker%20build.png)
- [바인드 마운트 변경 반영](evidence/33.%20docker%20bind%20after.png)
- [Docker 볼륨 영속성](evidence/37.%20docker%20volume%20persistence.png)

### Docker Compose

- [Compose 설정 검증](evidence/80.%20compose%20env%20config.png)
- [Compose 서비스 실행 상태](evidence/82.%20compose%20env%20ps.png)
- [웹페이지 접속 결과](evidence/83.%20compose%20env%20browser.png)

### Git 및 GitHub

- [Git 설정](evidence/57.%20git%20config%20list.png)
- [GitHub SSH 연결](evidence/90.%20github%20ssh%20remote.png)

기존 이미지 파일명은 증빙과 README의 연결을 유지하기 위해 변경하지 않았습니다.
