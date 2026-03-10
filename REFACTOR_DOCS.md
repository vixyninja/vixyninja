# Yêu cầu cấu trúc dotfiles cho Ubuntu Home Server dùng Zsh

## 1. Mục tiêu

Thiết kế một repository `dotfiles` chuẩn cho môi trường **Ubuntu home server** với shell chính là **Zsh**, đảm bảo các tiêu chí sau:

* Dễ quản lý, dễ mở rộng, dễ backup và restore.
* Tách biệt rõ:

  * cấu hình shell,
  * cấu hình user,
  * script vận hành,
  * cấu hình hệ thống,
  * cấu hình service,
  * dữ liệu nhạy cảm.
* Có thể bootstrap (khởi tạo) máy mới nhanh chóng.
* Phù hợp để dùng lâu dài trên server cá nhân hoặc homelab.
* Hạn chế nhồi toàn bộ logic vào một file `.zshrc` duy nhất.

---

## 2. Cấu trúc thư mục bắt buộc

Repository cần có cấu trúc như sau:

```bash
dotfiles/
├── README.md
├── install.sh
├── bootstrap.sh
├── .gitignore
├── .env.example
│
├── zsh/
│   ├── .zshrc
│   ├── aliases.zsh
│   ├── exports.zsh
│   ├── functions.zsh
│   ├── path.zsh
│   ├── completion.zsh
│   ├── prompt.zsh
│   └── plugins.zsh
│
├── home/
│   ├── .gitconfig
│   ├── .gitignore_global
│   ├── .tmux.conf
│   ├── .vimrc
│   ├── .profile
│   └── .config/
│       ├── nvim/
│       ├── btop/
│       ├── fastfetch/
│       ├── lazygit/
│       └── starship.toml
│
├── ssh/
│   ├── config.example
│   └── known_hosts.example
│
├── scripts/
│   ├── setup/
│   │   ├── install-packages.sh
│   │   ├── setup-zsh.sh
│   │   ├── setup-docker.sh
│   │   ├── setup-go.sh
│   │   ├── setup-node.sh
│   │   └── setup-security.sh
│   │
│   ├── server/
│   │   ├── backup.sh
│   │   ├── restore.sh
│   │   ├── healthcheck.sh
│   │   ├── update-system.sh
│   │   ├── cleanup.sh
│   │   └── rotate-logs.sh
│   │
│   └── utils/
│       ├── symlink.sh
│       ├── ensure-dir.sh
│       └── load-env.sh
│
├── system/
│   ├── systemd/
│   │   ├── backup.service
│   │   ├── backup.timer
│   │   ├── cleanup.service
│   │   └── cleanup.timer
│   │
│   ├── ufw/
│   │   └── rules.sh
│   │
│   ├── fail2ban/
│   │   └── jail.local
│   │
│   ├── sysctl/
│   │   └── 99-home-server.conf
│   │
│   └── cron/
│       └── crontab.example
│
├── services/
│   ├── docker/
│   │   ├── compose/
│   │   │   ├── portainer/
│   │   │   │   ├── docker-compose.yml
│   │   │   │   └── .env.example
│   │   │   ├── uptime-kuma/
│   │   │   ├── homepage/
│   │   │   ├── postgres/
│   │   │   └── redis/
│   │   └── scripts/
│   │       └── docker-prune.sh
│   │
│   ├── nginx/
│   │   ├── conf.d/
│   │   └── snippets/
│   │
│   └── caddy/
│       ├── Caddyfile
│       └── snippets/
│
├── secrets/
│   ├── env/
│   ├── ssh/
│   └── tokens/
│
└── docs/
    ├── server-setup.md
    ├── backup-restore.md
    ├── security.md
    └── troubleshooting.md
```

---

## 3. Quy tắc tổ chức thư mục

### 3.1 `zsh/`

Chứa toàn bộ cấu hình shell Zsh, không để logic dài dòng trực tiếp trong `.zshrc`.

Yêu cầu:

* `.zshrc` chỉ đóng vai trò entrypoint (điểm vào), dùng để `source` các file còn lại.
* Tách riêng từng nhóm cấu hình:

  * `aliases.zsh`: alias
  * `exports.zsh`: environment variables (biến môi trường)
  * `functions.zsh`: shell functions
  * `path.zsh`: PATH management
  * `completion.zsh`: completion
  * `prompt.zsh`: prompt
  * `plugins.zsh`: plugin loading

Ví dụ nội dung `zsh/.zshrc`:

```bash
export DOTFILES="$HOME/dotfiles"

source "$DOTFILES/zsh/exports.zsh"
source "$DOTFILES/zsh/path.zsh"
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/functions.zsh"
source "$DOTFILES/zsh/completion.zsh"
source "$DOTFILES/zsh/plugins.zsh"
source "$DOTFILES/zsh/prompt.zsh"
```

---

### 3.2 `home/`

Chứa các file cần symlink (liên kết mềm) hoặc copy vào `$HOME`.

Bao gồm:

* `.gitconfig`
* `.gitignore_global`
* `.tmux.conf`
* `.vimrc`
* `.profile`
* các thư mục con trong `.config/`

---

### 3.3 `ssh/`

Chỉ chứa file mẫu, không chứa private key thật.

Yêu cầu:

* Có `config.example`
* Có `known_hosts.example`
* Không commit private key hoặc secret SSH thật

---

### 3.4 `scripts/`

Chia rõ thành 3 nhóm:

#### `scripts/setup/`

Dùng để setup ban đầu cho máy mới:

* cài package
* setup zsh
* setup docker
* setup go
* setup node
* setup security

#### `scripts/server/`

Dùng cho vận hành server:

* backup
* restore
* healthcheck
* update system
* cleanup
* rotate logs

#### `scripts/utils/`

Dùng cho helper:

* symlink file
* ensure directory
* load env

---

### 3.5 `system/`

Chứa cấu hình mức hệ thống.

Bắt buộc có:

* `systemd/`: service và timer
* `ufw/`: firewall rules
* `fail2ban/`: brute-force protection
* `sysctl/`: kernel tuning
* `cron/`: crontab example

---

### 3.6 `services/`

Chứa cấu hình service chạy trên server.

Yêu cầu:

* Có phân nhóm cho Docker Compose.
* Mỗi service là một thư mục riêng.
* Có thể thêm reverse proxy config bằng Nginx hoặc Caddy.

Cấu trúc gợi ý:

* `services/docker/compose/portainer`
* `services/docker/compose/uptime-kuma`
* `services/docker/compose/homepage`
* `services/docker/compose/postgres`
* `services/docker/compose/redis`

---

### 3.7 `secrets/`

Chứa dữ liệu nhạy cảm và **không được commit**.

Bao gồm:

* file `.env`
* SSH key
* token
* API key

---

### 3.8 `docs/`

Chứa tài liệu vận hành:

* quy trình setup server
* backup/restore
* security hardening
* troubleshooting

---

## 4. Quy tắc nội dung các file chính

## 4.1 `install.sh`

Script cài đặt chính của repository.

Yêu cầu:

* Tạo symlink từ repo sang `$HOME`
* Tạo các thư mục cần thiết nếu chưa có
* Copy file mẫu nếu file thật chưa tồn tại
* Có xử lý lỗi cơ bản
* Có thể chạy nhiều lần mà không phá cấu hình cũ nếu đã tồn tại

---

## 4.2 `bootstrap.sh`

Script bootstrap tổng cho máy mới.

Yêu cầu:

* Gọi các script trong `scripts/setup/`
* Thiết lập thứ tự hợp lý
* Có log rõ ràng từng bước

Ví dụ thứ tự:

1. install packages
2. setup zsh
3. setup docker
4. setup go
5. setup node
6. setup security
7. run install.sh

---

## 4.3 `.gitignore`

Bắt buộc ignore toàn bộ dữ liệu nhạy cảm.

Ví dụ:

```gitignore
secrets/
.env
.env.*
*.pem
*.key
*.pub
.DS_Store
```

---

## 5. Quy tắc naming (đặt tên)

Bắt buộc thống nhất:

* File cấu hình Zsh dùng đuôi `.zsh`
* Script shell dùng đuôi `.sh`
* File mẫu dùng đuôi `.example`
* Tài liệu dùng `.md`

Ví dụ hợp lệ:

* `aliases.zsh`
* `backup.sh`
* `config.example`
* `server-setup.md`

Không dùng naming lộn xộn như:

* `alias.sh`
* `zsh_alias`
* `backup-final-v2.sh`

---

## 6. Yêu cầu tối thiểu cho Zsh

Bắt buộc tạo các file sau trong `zsh/`:

* `.zshrc`
* `aliases.zsh`
* `exports.zsh`
* `functions.zsh`
* `path.zsh`
* `prompt.zsh`
* `plugins.zsh`

Có thể thêm `completion.zsh`.

---

## 7. Ví dụ nội dung tối thiểu

### `aliases.zsh`

```bash
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
```

### `exports.zsh`

```bash
export EDITOR=nvim
export VISUAL=nvim
export GOPATH="$HOME/go"
export DOTFILES="$HOME/dotfiles"
```

### `path.zsh`

```bash
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/go/bin"
  $path
)
export PATH
```

### `functions.zsh`

```bash
mkcd() {
  mkdir -p "$1" && cd "$1"
}

dlogs() {
  docker compose logs -f "${1:-}"
}
```

---

## 8. Yêu cầu triển khai

Agentic coding cần thực hiện các việc sau:

### 8.1 Tạo đầy đủ cây thư mục

Sinh chính xác cấu trúc thư mục như phần yêu cầu.

### 8.2 Tạo file placeholder (khung file)

Với các file chưa có nội dung đầy đủ, tạo sẵn nội dung tối thiểu hoặc comment mô tả mục đích.

### 8.3 Tạo script cài đặt cơ bản

Sinh:

* `install.sh`
* `bootstrap.sh`
* `scripts/utils/symlink.sh`
* `scripts/utils/ensure-dir.sh`

### 8.4 Tạo cấu hình Zsh tối thiểu dùng được

Đảm bảo:

* `.zshrc` có thể source toàn bộ file con
* không lỗi nếu một số tool chưa được cài
* không hardcode (ghi cứng) path không cần thiết ngoài `$HOME/dotfiles`

### 8.5 Tạo tài liệu README.md

README cần mô tả:

* mục đích repo
* cấu trúc thư mục
* cách cài đặt
* cách bootstrap máy mới
* cách thêm service mới
* cách quản lý secrets

---

## 9. Tiêu chí hoàn thiện

Kết quả được xem là đạt khi:

* Có cấu trúc rõ ràng, đúng phân tầng.
* Zsh config tách module, không nhồi toàn bộ vào `.zshrc`.
* Có script cài đặt và bootstrap cơ bản.
* Có sẵn nơi chứa cấu hình server/service/security.
* Secrets được tách riêng và ignore.
* Có thể dùng repo này làm nền tảng lâu dài cho Ubuntu home server.

---

## 10. Output mong muốn cho agent

Agent cần trả ra theo một trong hai dạng sau:

### Cách 1

Sinh trực tiếp toàn bộ cây thư mục + nội dung file mẫu.

### Cách 2

Nếu làm theo từng bước, thứ tự ưu tiên:

1. tạo cấu trúc thư mục,
2. tạo nhóm `zsh/`,
3. tạo `install.sh` và `bootstrap.sh`,
4. tạo `scripts/`,
5. tạo `system/`,
6. tạo `services/`,
7. tạo `README.md`.

---

## 11. Chốt yêu cầu ngắn gọn

Hãy tạo một repository `dotfiles` chuẩn cho **Ubuntu home server** dùng **Zsh**, có cấu trúc rõ ràng giữa:

* `zsh/`
* `home/`
* `ssh/`
* `scripts/`
* `system/`
* `services/`
* `secrets/`
* `docs/`

Kèm theo:

* `install.sh`
* `bootstrap.sh`
* Zsh modular config
* README hướng dẫn sử dụng
* `.gitignore` cho secrets
* file mẫu cho system/service/ssh/configurations

Mục tiêu là để repo này có thể dùng ngay làm nền tảng quản lý cấu hình server cá nhân một cách sạch, chuẩn và dễ mở rộng.
