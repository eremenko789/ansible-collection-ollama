# Ansible коллекция Community Ollama

Эта коллекция Ansible предоставляет роли и модули для управления [Ollama](https://ollama.ai/) с помощью Docker.

## Содержание

- [Установка](#установка)
- [Роли](#роли)
- [Примеры использования](#примеры-использования)
- [Требования](#требования)
- [Тестирование](#тестирование)
- [Участие в разработке](#участие-в-разработке)

## Установка

### Из Ansible Galaxy

```bash
ansible-galaxy collection install community.ollama
```

### Из исходного кода

```bash
git clone https://github.com/community/ollama-ansible-collection.git
cd ollama-ansible-collection
ansible-galaxy collection build
ansible-galaxy collection install community-ollama-*.tar.gz
```

## Роли

### ollama

Основная роль для развертывания Ollama с использованием Docker.

**Особенности:**
- Использует проверенную роль `geerlingguy.docker` для установки Docker
- Поддержка GPU (NVIDIA)
- Гибкая конфигурация volumes
- Предварительная загрузка моделей
- Мониторинг и проверка работоспособности
- Автоматическое управление зависимостями

**Поддерживаемые ОС:**
- Ubuntu 24.04
- Ubuntu 22.04
- Ubuntu 20.04

[Подробная документация роли](roles/ollama/README.md)

## Примеры использования

### Быстрый старт

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - community.ollama.ollama
```

### С предустановленными моделями

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - role: community.ollama.ollama
      vars:
        ollama_preload_models:
          - llama2
          - mistral
          - codellama
```

### С GPU поддержкой

```yaml
- hosts: gpu_servers
  become: yes
  roles:
    - role: community.ollama.ollama
      vars:
        ollama_enable_gpu: true
        ollama_memory_limit: "8g"
        ollama_cpus: "4.0"
```

### Полная конфигурация

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - role: community.ollama.ollama
      vars:
        # Основные настройки
        ollama_version: "latest"
        ollama_port: 11434
        
        # Volumes
        ollama_use_host_volumes: true
        ollama_host_data_path: "/srv/ollama/data"
        ollama_host_models_path: "/srv/ollama/models"
        
        # Ресурсы
        ollama_memory_limit: "8g"
        ollama_cpus: "4.0"
        
        # GPU
        ollama_enable_gpu: true
        
        # Модели
        ollama_preload_models:
          - llama2
          - mistral
          - codellama
        
        # Безопасность
        ollama_security_opts:
          - "no-new-privileges:true"
```

## Требования

### Управляющий узел (Control Node)

- Ansible >= 2.9
- Python >= 3.8

### Управляемые узлы (Managed Nodes)

- Ubuntu 20.04/22.04/24.04
- Python 3
- sudo права

### Зависимости Ansible

```yaml
roles:
  - geerlingguy.docker >= 7.0.0

collections:
  - community.docker >= 3.0.0
  - community.general >= 1.0.0
```

### Для GPU поддержки

- NVIDIA GPU
- NVIDIA драйверы
- nvidia-container-toolkit

## Тестирование

Коллекция включает тесты Molecule для двух сценариев:

### Docker тестирование

```bash
molecule test
```

### Proxmox тестирование

```bash
# Настройте переменные окружения для Proxmox
export PROXMOX_HOST="your-proxmox-server.local"
export PROXMOX_USER="root@pam"
export PROXMOX_PASSWORD="your-password"
export PROXMOX_NODE="your-node-name"

# Запуск тестов
molecule test -s proxmox
```

[Подробная документация по тестированию](molecule/README.md)

## Inventory пример

```ini
[ollama_servers]
server1 ansible_host=192.168.1.10
server2 ansible_host=192.168.1.11

[gpu_servers]
gpu1 ansible_host=192.168.1.20 ollama_enable_gpu=true
gpu2 ansible_host=192.168.1.21 ollama_enable_gpu=true

[ollama_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ollama_memory_limit=4g
ollama_cpus=2.0

[gpu_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ollama_memory_limit=8g
ollama_cpus=4.0
```

## Playbook пример

```yaml
---
- name: Deploy Ollama
  hosts: all
  become: yes
  gather_facts: yes
  
  vars:
    ollama_preload_models:
      - llama2
      - mistral
    ollama_use_host_volumes: true
    ollama_host_data_path: "/opt/ollama/data"
    ollama_host_models_path: "/opt/ollama/models"
  
  roles:
    - role: community.ollama.ollama
      tags: ['ollama']
  
  post_tasks:
    - name: Verify Ollama is working
      uri:
        url: "http://{{ ansible_default_ipv4.address }}:{{ ollama_port }}/api/version"
        method: GET
      delegate_to: localhost
      run_once: true
```

## Теги

Доступные теги для выборочного выполнения:

- `ollama` - все задачи
- `prepare` - подготовка системы
- `volumes` - настройка volumes
- `container` - развертывание контейнера
- `models` - загрузка моделей

```bash
# Только подготовка системы и контейнер
ansible-playbook playbook.yml --tags "prepare,container"

# Только загрузка моделей
ansible-playbook playbook.yml --tags "models"
```

## Переменные окружения

Для удобства можно использовать переменные окружения:

```bash
export OLLAMA_VERSION="0.1.0"
export OLLAMA_ENABLE_GPU="true"
export OLLAMA_MEMORY_LIMIT="8g"
```

## Мониторинг

После развертывания доступны следующие endpoints:

- `http://host:11434/api/version` - версия Ollama
- `http://host:11434/api/tags` - список моделей
- `http://host:11434/api/ps` - запущенные модели

### Prometheus метрики

Для мониторинга можно использовать:

```bash
# Статус сервиса
curl -s http://host:11434/api/version | jq '.version'

# Список моделей
curl -s http://host:11434/api/tags | jq '.models[].name'
```

## Участие в разработке

1. Fork репозитория
2. Создайте feature branch
3. Внесите изменения
4. Добавьте тесты
5. Запустите тесты: `molecule test`
6. Создайте Pull Request

### Структура проекта

```
community.ollama/
├── galaxy.yml                    # Метаданные коллекции
├── README.md                     # Основная документация
├── roles/
│   └── ollama/                   # Роль Ollama
│       ├── defaults/main.yml     # Переменные по умолчанию
│       ├── tasks/main.yml        # Основные задачи
│       ├── tasks/prepare.yml     # Подготовка системы
│       ├── tasks/volumes.yml     # Управление volumes
│       ├── tasks/container.yml   # Развертывание контейнера
│       ├── tasks/models.yml      # Загрузка моделей
│       ├── handlers/main.yml     # Обработчики событий
│       ├── meta/main.yml         # Метаданные роли
│       └── README.md             # Документация роли
└── molecule/                     # Тесты Molecule
    ├── default/                  # Docker тесты
    ├── proxmox/                  # Proxmox тесты
    └── README.md                 # Документация тестирования
```

## Лицензия

GPL-2.0-or-later

## Авторы

Community Ollama Collection Team

## Поддержка

- [GitHub Issues](https://github.com/community/ollama-ansible-collection/issues)
- [GitHub Discussions](https://github.com/community/ollama-ansible-collection/discussions)

## Changelog

### v1.0.0

- Первоначальный релиз
- Роль для развертывания Ollama с Docker
- Поддержка GPU
- Тесты Molecule с Docker и Proxmox
- Полная документация на русском языке
