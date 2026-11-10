# Codyssey E1-1 — 개발 환경 구축

경남 코디세이 E1-1 미션 수행을 위한 저장소입니다.

Windows 환경에서 WSL2와 Ubuntu를 사용하여 Linux 개발 환경을 구축하고, Docker 및 Docker Compose로 웹서버 컨테이너를 실행하였습니다. Git과 GitHub를 통해 프로젝트 파일과 실습 증빙을 관리하였습니다.

## 1. 개발 환경

| 항목 | 환경 |
|---|---|
| 운영체제 | Windows + WSL2 |
| Linux 배포판 | Ubuntu 26.04.1 LTS |
| WSL 커널 | 6.18.54.1-microsoft-standard-WSL2 |
| Docker | Docker Desktop / Docker Engine 29.9.2 |
| Docker Compose | v5.6.1 |
| Git | 2.53.0 |
| 코드 편집기 | Visual Studio Code (WSL 연결) |
| 웹서버 | Nginx (Alpine Linux 기반 이미지) |

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
    └── 실습 증빙 이미지
```

`.env` 파일은 로컬 환경 변수 설정에 사용하며, `.gitignore`를 통해 Git 추적에서 제외하였습니다.

## 3. Linux 개발 환경 및 기본 명령어

WSL2에 Ubuntu를 설치한 뒤 Linux 배포판과 커널 정보를 확인하였습니다.

주요 수행 내용은 다음과 같습니다.

- Linux 파일 및 디렉터리 생성·조회·복사·이동·삭제
- 파일 권한 확인 및 `chmod 600`, `chmod 644` 적용
- 디렉터리 권한 `chmod 700`, `chmod 755` 적용
- Linux 사용자 및 프로세스 확인
- VS Code와 WSL Ubuntu 연동

**증빙**

- [WSL 환경 확인](evidence/1.%20wsl-version.png)
- [Ubuntu 배포판 확인](evidence/3.%20ubuntu-release.png)
- [Linux 파일 작업](evidence/6.%20linux-file-operations.png)
- [파일 권한 변경](evidence/8.%20chmod-600.png)
- [디렉터리 권한 변경](evidence/10.%20directory-chmod-700.png)

## 4. Docker 이미지 및 컨테이너

Docker Desktop과 WSL2를 연동하여 Docker 명령어를 실행할 수 있는 환경을 구축하였습니다.

Ubuntu 및 Hello World 이미지를 이용하여 컨테이너를 생성하고 실행 결과를 확인하였습니다.

또한 `docker exec`와 `docker attach`의 동작 차이를 관찰하였습니다.

- `docker exec`로 실행한 별도 Bash 셸을 종료한 경우 컨테이너가 계속 실행되었습니다.
- `docker attach`로 연결한 주 Bash 프로세스를 종료한 경우 컨테이너가 종료되었습니다.

**증빙**

- [Docker 실행 환경](evidence/12.%20docker-desktop.png)
- [Hello World 컨테이너](evidence/15.%20docker-hello-world.png)
- [exec 접속 후 컨테이너 유지](evidence/60.%20docker%20exec%20persistence.png)
- [attach 접속 후 컨테이너 종료](evidence/61.%20docker%20attach%20exit.png)

## 5. Dockerfile 기반 커스텀 이미지

Nginx Alpine 이미지를 기반으로 정적 HTML 웹페이지를 제공하는 커스텀 Docker 이미지를 제작하였습니다.

이미지 이름은 `codyssey-web:1.0`입니다.

Dockerfile:

```dockerfile
FROM nginx:alpine

LABEL description="Codyssey workstation web server"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```

이미지 빌드:

```bash
docker build -t codyssey-web:1.0 .
```

컨테이너 실행 후 브라우저에서 `Hello, Codyssey!` 웹페이지가 표시되는 것을 확인하였습니다.

**증빙**

- [Dockerfile 작성](evidence/23.%20dockerfile%20source.png)
- [Docker 이미지 빌드](evidence/25.%20docker%20build.png)
- [웹페이지 실행](evidence/27.%20docker%20browser.png)

## 6. 포트 매핑, 바인드 마운트, Docker 볼륨

### 포트 매핑

호스트의 서로 다른 포트를 컨테이너 내부의 80번 포트와 연결하여 여러 웹서버를 동시에 실행하였습니다.

### 바인드 마운트

호스트의 `site/` 디렉터리를 컨테이너의 웹 콘텐츠 디렉터리에 읽기 전용으로 연결하였습니다.

호스트 HTML 파일을 수정했을 때 바인드 마운트를 적용한 웹서버에는 변경 사항이 즉시 반영되는 것을 확인하였습니다.

### Docker 볼륨

`codyssey-data` 볼륨을 생성하고 컨테이너 내부에 파일을 저장하였습니다.

기존 컨테이너를 삭제한 후 동일한 볼륨을 연결한 새로운 컨테이너에서 해당 파일을 읽어 데이터가 유지됨을 확인하였습니다.

**증빙**

- [포트 매핑](evidence/29.%20docker%20port%20mapping.png)
- [바인드 마운트 적용 전](evidence/32.%20docker%20bind%20before.png)
- [바인드 마운트 적용 후](evidence/33.%20docker%20bind%20after.png)
- [Docker 볼륨 데이터 유지](evidence/37.%20docker%20volume%20persistence.png)

## 7. Docker Compose

Docker Compose를 사용하여 두 개의 웹서버 서비스를 구성하였습니다.

`compose.yaml`:

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

환경 변수 예시인 `.env.example`에는 다음 값을 정의하였습니다.

```dotenv
WEB_PORT=8083
WEB2_PORT=8085
```

실행 방법:

```bash
docker build -t codyssey-web:1.0 .
cp .env.example .env
docker compose config
docker compose up -d
docker compose ps
```

웹페이지 접속 주소:

- 첫 번째 서비스: `http://localhost:8083`
- 두 번째 서비스: `http://localhost:8085`

운영 과정에서 `docker compose logs`, `stop`, `start`, `down`, `up -d` 등의 명령어를 실행하고 결과를 확인하였습니다.

**증빙**

- [Compose 설정](evidence/63.%20docker%20compose%20yaml.png)
- [Compose 멀티 컨테이너](evidence/71.%20compose%20multicontainer%20browser.png)
- [Compose 운영 명령어](evidence/76.%20compose%20down.png)
- [환경 변수 적용 결과](evidence/83.%20compose%20env%20browser.png)

## 8. Git 및 GitHub

Git 사용자 정보를 설정하고 기본 브랜치를 `main`으로 지정하였습니다.

프로젝트 파일을 Git으로 버전 관리하고 GitHub 원격 저장소에 업로드하였습니다.

또한 Ed25519 SSH 키를 생성하여 GitHub에 공개 키를 등록하였고, SSH 인증 및 원격 저장소 접근이 정상적으로 작동하는 것을 확인하였습니다.

**증빙**

- [Git 기본 브랜치 설정](evidence/56.%20git%20default%20branch.png)
- [Git 전체 설정 확인](evidence/57.%20git%20config%20list.png)
- [GitHub SSH 인증](evidence/89.%20github%20ssh%20authentication.png)
- [GitHub SSH 원격 연결](evidence/90.%20github%20ssh%20remote.png)

## 9. 실습 증빙 자료

전체 실습 과정에서 생성한 증빙 이미지는 [`evidence/`](evidence/) 디렉터리에 보관하였습니다.

각 이미지에는 환경 설정, 명령어 실행, 결과 검증, 컨테이너 상태 및 브라우저 접속 화면 등이 포함되어 있습니다.
