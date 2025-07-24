# Обновления коллекции Community Ollama

## Основные изменения

### 1. Использование роли geerlingguy.docker

**Было:**
- Ручная установка Docker через apt
- Множество задач для настройки репозитория, GPG ключей, установки пакетов

**Стало:**
- Использование проверенной роли `geerlingguy.docker` версии >=7.0.0
- Упрощенная и надежная установка Docker
- Гибкая конфигурация через переменные роли

### 2. Добавлен argument_specs.yml

Создан файл `roles/ollama/meta/argument_specs.yml` с полным описанием всех переменных роли:
- Типы данных
- Значения по умолчанию
- Описания переменных
- Валидация входных параметров
- Поддержка автодополнения в IDE

### 3. Обновленные зависимости

**Новые зависимости в meta/main.yml:**
```yaml
dependencies:
  - name: geerlingguy.docker
    version: ">=7.0.0"
  - name: community.docker
    version: ">=3.0.0"
```

### 4. Новые файлы и обновления

#### Новые файлы:
- `roles/ollama/meta/argument_specs.yml` - валидация аргументов
- `ansible-requirements.yml` - установка зависимостей
- `setup.sh` - скрипт автоматической установки

#### Обновленные файлы:
- `roles/ollama/defaults/main.yml` - добавлены переменные Docker
- `roles/ollama/tasks/prepare.yml` - использование роли geerlingguy.docker
- `molecule/*/requirements.yml` - добавлена роль Docker
- `README.md` - обновлена документация
- `roles/ollama/README.md` - добавлена информация о Docker роли

### 5. Переменные конфигурации Docker

Добавлены новые переменные для настройки Docker:

```yaml
# Установка Docker Compose
docker_install_compose: true
docker_install_compose_plugin: true

# Пользователи для группы docker
docker_users: []

# Конфигурация Docker daemon
docker_daemon_options: {}

# Состояние для restart handler
docker_restart_handler_state: "restarted"
```

### 6. Обновленные примеры

**Inventory (`examples/inventory.ini`):**
```ini
[all:vars]
docker_users=['ubuntu']
```

**Playbooks:**
- Добавлена конфигурация Docker пользователей
- Примеры настройки Docker daemon

### 7. Улучшенная установка

**Новый процесс установки:**
```bash
# Автоматическая установка
./setup.sh

# Или ручная установка
ansible-galaxy install -r ansible-requirements.yml
ansible-galaxy collection install community.ollama
```

## Преимущества изменений

### 🔧 Надежность
- Использование проверенной роли geerlingguy.docker
- Лучшая поддержка различных версий Ubuntu
- Улучшенная обработка ошибок

### 📝 Валидация
- Полная валидация входных параметров
- Автодополнение в IDE
- Улучшенная документация переменных

### 🚀 Простота использования
- Автоматический скрипт установки
- Упрощенная настройка зависимостей
- Готовые примеры конфигурации

### 🔒 Безопасность
- Использование официальных репозиториев Docker
- Проверенные методы установки
- Конфигурация групп пользователей

### 📚 Документация
- Полное описание всех переменных
- Примеры для различных сценариев
- Troubleshooting руководство

## Обратная совместимость

Все изменения сохраняют обратную совместимость:
- Существующие playbooks продолжат работать
- Значения переменных по умолчанию не изменились
- API роли остался неизменным

## Миграция

Для существующих пользователей:
1. Установите зависимости: `ansible-galaxy install -r ansible-requirements.yml`
2. Обновите коллекцию: `ansible-galaxy collection install community.ollama --force`
3. Опционально: настройте переменные Docker в соответствии с новыми возможностями

## Тестирование

Все изменения протестированы с:
- Molecule тестами (Docker и Proxmox)
- Различными конфигурациями Ubuntu
- GPU и без GPU сценариями