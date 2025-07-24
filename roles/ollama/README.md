# Роль Ollama

Эта роль развертывает Ollama с использованием Docker на Ubuntu 24.04. Ollama — это инструмент для запуска больших языковых моделей локально.

## Требования

- Ubuntu 24.04 (также поддерживает 22.04 и 20.04)
- Ansible >= 2.9
- Коллекция `community.docker` >= 3.0.0

## Переменные роли

### Основные параметры

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_version` | `latest` | Версия Docker образа Ollama |
| `ollama_image` | `ollama/ollama` | Docker образ Ollama |
| `ollama_container_name` | `ollama` | Имя Docker контейнера |

### Сетевые настройки

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_port` | `11434` | Порт для API Ollama |
| `ollama_host` | `0.0.0.0` | Хост для привязки сервиса |
| `ollama_additional_ports` | `[]` | Дополнительные порты для проброса |

### Настройки volumes

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_use_host_volumes` | `false` | Использовать директории хоста вместо Docker volumes |
| `ollama_data_volume` | `ollama_data` | Имя Docker volume для данных |
| `ollama_models_volume` | `ollama_models` | Имя Docker volume для моделей |
| `ollama_host_data_path` | `/opt/ollama/data` | Путь к данным на хосте |
| `ollama_host_models_path` | `/opt/ollama/models` | Путь к моделям на хосте |

### Ресурсы контейнера

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_memory_limit` | `4g` | Ограничение памяти |
| `ollama_cpus` | `2.0` | Количество CPU |
| `ollama_restart_policy` | `unless-stopped` | Политика перезапуска |

### GPU поддержка

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_enable_gpu` | `false` | Включить поддержку GPU |
| `ollama_gpu_device_requests` | См. defaults/main.yml | Настройки GPU устройств |

### Модели

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_preload_models` | `[]` | Список моделей для предварительной загрузки |

### Пользователи и безопасность

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `ollama_user` | `ollama` | Пользователь для работы с файлами |
| `ollama_group` | `ollama` | Группа для работы с файлами |
| `ollama_uid` | `1000` | UID пользователя |
| `ollama_gid` | `1000` | GID группы |
| `ollama_security_opts` | `[]` | Опции безопасности для контейнера |

### Docker установка (geerlingguy.docker)

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `docker_install_compose` | `true` | Установка Docker Compose |
| `docker_install_compose_plugin` | `true` | Установка Docker Compose plugin |
| `docker_users` | `[]` | Пользователи для добавления в группу docker |
| `docker_daemon_options` | `{}` | Опции конфигурации Docker daemon |
| `docker_restart_handler_state` | `restarted` | Состояние для restart handler |

## Зависимости

```yaml
dependencies:
  - name: geerlingguy.docker
    version: ">=7.0.0"
  - name: community.docker
    version: ">=3.0.0"
```

## Примеры использования

### Базовое развертывание

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - community.ollama.ollama
```

### Развертывание с предустановленными моделями

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - role: community.ollama.ollama
      vars:
        ollama_preload_models:
          - llama2
          - codellama
```

### Развертывание с host volumes

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - role: community.ollama.ollama
      vars:
        ollama_use_host_volumes: true
        ollama_host_data_path: "/srv/ollama/data"
        ollama_host_models_path: "/srv/ollama/models"
```

### Развертывание с настройкой Docker пользователей

```yaml
- hosts: ollama_servers
  become: yes
  roles:
    - role: community.ollama.ollama
      vars:
        docker_users:
          - "{{ ansible_user }}"
          - ubuntu
        docker_daemon_options:
          log-driver: "json-file"
          log-opts:
            max-size: "10m"
            max-file: "3"
```

### Развертывание с GPU поддержкой

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
        ollama_version: "latest"
        ollama_port: 11434
        ollama_use_host_volumes: true
        ollama_host_data_path: "/srv/ollama/data"
        ollama_host_models_path: "/srv/ollama/models"
        ollama_memory_limit: "8g"
        ollama_cpus: "4.0"
        ollama_enable_gpu: true
        ollama_preload_models:
          - llama2
          - mistral
        ollama_additional_ports:
          - "8080:8080"
        ollama_security_opts:
          - "no-new-privileges:true"
```

## Теги

Доступные теги для выборочного выполнения задач:

- `ollama` - все задачи роли
- `prepare` - подготовка системы
- `volumes` - управление volumes
- `container` - развертывание контейнера
- `models` - загрузка моделей

Пример использования тегов:

```bash
ansible-playbook -i inventory playbook.yml --tags "prepare,container"
```

## Обработчики

Роль предоставляет следующие обработчики:

- `restart ollama` - перезапуск контейнера Ollama
- `stop ollama` - остановка контейнера Ollama
- `start ollama` - запуск контейнера Ollama
- `reload docker` - перезагрузка службы Docker
- `restart docker` - перезапуск службы Docker

## Проверка состояния

После развертывания роль автоматически проверяет:

1. Статус контейнера Docker
2. Доступность API Ollama
3. Успешность загрузки моделей (если указаны)

## API Endpoints

После успешного развертывания доступны следующие API endpoints:

- `GET http://host:11434/api/version` - версия Ollama
- `GET http://host:11434/api/tags` - список установленных моделей
- `POST http://host:11434/api/pull` - загрузка модели
- `POST http://host:11434/api/generate` - генерация текста

## Устранение неисправностей

### Контейнер не запускается

1. Проверьте логи контейнера:
   ```bash
   docker logs ollama
   ```

2. Проверьте доступность образа:
   ```bash
   docker pull ollama/ollama:latest
   ```

### API недоступен

1. Проверьте, что контейнер запущен:
   ```bash
   docker ps | grep ollama
   ```

2. Проверьте порты:
   ```bash
   netstat -tlnp | grep 11434
   ```

### Проблемы с GPU

1. Убедитесь, что установлен nvidia-container-toolkit
2. Проверьте доступность GPU в контейнере:
   ```bash
   docker exec ollama nvidia-smi
   ```

### Проблемы с volumes

1. Для host volumes проверьте права доступа:
   ```bash
   ls -la /opt/ollama/
   ```

2. Для Docker volumes проверьте их существование:
   ```bash
   docker volume ls | grep ollama
   ```

## Лицензия

GPL-2.0-or-later

## Автор

Community Ollama Collection Team