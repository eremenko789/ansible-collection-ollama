# Тестирование роли Ollama с Molecule

Эта роль включает два сценария тестирования:
- `default` - тестирование с Docker контейнерами
- `proxmox` - тестирование на реальных VMs в Proxmox

## Требования

### Общие требования

```bash
pip install molecule[docker]
pip install molecule-plugins[docker]
pip install molecule-plugins[proxmox]
```

### Для тестирования с Docker

- Docker
- Docker Python библиотека

### Для тестирования с Proxmox

- Доступ к Proxmox VE кластеру
- Шаблон Ubuntu 24.04 в Proxmox
- SSH ключи для доступа к VM

## Настройка Proxmox тестирования

### 1. Переменные окружения

Создайте файл `.env` или установите переменные окружения:

```bash
export PROXMOX_HOST="your-proxmox-server.local"
export PROXMOX_USER="root@pam"
export PROXMOX_PASSWORD="your-password"
export PROXMOX_NODE="your-node-name"
```

### 2. Создание шаблона Ubuntu 24.04

1. Скачайте Ubuntu 24.04 cloud image:
   ```bash
   wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img
   ```

2. Создайте VM шаблон в Proxmox:
   ```bash
   # Создайте VM
   qm create 9000 --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
   
   # Импортируйте диск
   qm importdisk 9000 ubuntu-24.04-server-cloudimg-amd64.img local-lvm
   
   # Присоедините диск
   qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
   
   # Добавьте cloud-init диск
   qm set 9000 --ide2 local-lvm:cloudinit
   
   # Настройте загрузку
   qm set 9000 --boot c --bootdisk scsi0
   
   # Добавьте serial console
   qm set 9000 --serial0 socket --vga serial0
   
   # Настройте cloud-init
   qm set 9000 --ciuser ubuntu
   qm set 9000 --sshkey ~/.ssh/id_rsa.pub
   
   # Преобразуйте в шаблон
   qm template 9000
   ```

3. Переименуйте шаблон:
   ```bash
   # В интерфейсе Proxmox переименуйте VM 9000 в "ubuntu-24.04-template"
   ```

### 3. SSH ключи

Убедитесь, что у вас есть SSH ключи:

```bash
# Создайте ключи если их нет
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Добавьте публичный ключ в шаблон при его создании
```

## Запуск тестов

### Docker тестирование

```bash
# Запуск полного цикла тестирования
molecule test

# Запуск только конвергенции
molecule converge

# Запуск только верификации
molecule verify

# Очистка
molecule destroy
```

### Proxmox тестирование

```bash
# Установите переменные окружения
source .env

# Запуск тестирования с Proxmox
molecule test -s proxmox

# Создание VM
molecule create -s proxmox

# Конвергенция (развертывание роли)
molecule converge -s proxmox

# Верификация
molecule verify -s proxmox

# Очистка
molecule destroy -s proxmox
```

## Отладка

### Просмотр логов

```bash
# Логи контейнера Docker
molecule login

# Для Proxmox - подключение к VM
molecule login -s proxmox
```

### Ручное тестирование

```bash
# Создание инфраструктуры без конвергенции
molecule create -s proxmox

# Ручной запуск ansible
molecule converge -s proxmox

# Подключение к VM для отладки
ssh ubuntu@<vm-ip>
```

## Структура тестов

### Default сценарий (Docker)

- Использует Ubuntu 24.04 контейнер
- Устанавливает Docker в контейнере
- Развертывает Ollama без GPU поддержки
- Не загружает модели (для ускорения тестов)
- Проверяет базовую функциональность

### Proxmox сценарий

- Создает реальную VM с Ubuntu 24.04
- Полная установка Docker и Ollama
- Тестирует с host volumes
- Загружает тестовую модель (tinyllama)
- Проверяет генерацию текста
- Тестирует производительность

## Настройка тестов

### Изменение конфигурации

Отредактируйте файлы в `molecule/*/`:

- `molecule.yml` - основная конфигурация
- `converge.yml` - playbook для развертывания
- `verify.yml` - тесты для проверки

### Добавление новых тестов

Добавьте задачи в `verify.yml`:

```yaml
- name: Your custom test
  ansible.builtin.command:
    cmd: your-test-command
  register: test_result

- name: Verify test result
  ansible.builtin.assert:
    that:
      - test_result.rc == 0
    fail_msg: "Test failed"
    success_msg: "Test passed"
```

## Troubleshooting

### Проблемы с Proxmox

1. **VM не создается**:
   - Проверьте переменные окружения
   - Убедитесь, что шаблон существует
   - Проверьте права доступа к Proxmox API

2. **SSH не работает**:
   - Проверьте SSH ключи
   - Убедитесь, что cloud-init настроен в шаблоне
   - Проверьте сетевые настройки

3. **Таймауты**:
   - Увеличьте timeout в molecule.yml
   - Проверьте производительность Proxmox сервера

### Проблемы с Docker

1. **Контейнер не запускается**:
   - Проверьте права Docker
   - Убедитесь, что systemd работает в контейнере

2. **Ollama не отвечает**:
   - Проверьте логи контейнера: `docker logs ollama`
   - Увеличьте timeout для запуска

## CI/CD интеграция

### GitHub Actions

```yaml
name: Molecule Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          pip install molecule[docker]
          pip install molecule-plugins[docker]
      - name: Run Molecule tests
        run: molecule test
```

### GitLab CI

```yaml
molecule-test:
  image: python:3.9
  services:
    - docker:dind
  before_script:
    - pip install molecule[docker] molecule-plugins[docker]
  script:
    - molecule test
```