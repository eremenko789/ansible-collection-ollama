#!/bin/bash
# Скрипт для быстрой установки коллекции Community Ollama

set -e

echo "=== Community Ollama Collection Setup ==="
echo

# Проверка наличия Ansible
if ! command -v ansible-galaxy &> /dev/null; then
    echo "❌ Ansible не установлен. Пожалуйста, установите Ansible сначала."
    exit 1
fi

echo "✅ Ansible найден: $(ansible --version | head -n1)"

# Установка зависимостей
echo "📦 Установка зависимостей..."
if [ -f "ansible-requirements.yml" ]; then
    ansible-galaxy install -r ansible-requirements.yml
    echo "✅ Зависимости установлены"
else
    echo "⚠️  Файл ansible-requirements.yml не найден"
    echo "📦 Установка роли geerlingguy.docker..."
    ansible-galaxy install geerlingguy.docker
fi

# Установка коллекций
echo "📦 Установка коллекций..."
ansible-galaxy collection install community.docker community.general

# Сборка коллекции (если находимся в исходном коде)
if [ -f "galaxy.yml" ]; then
    echo "🔨 Сборка коллекции..."
    ansible-galaxy collection build --force
    
    echo "📦 Установка собранной коллекции..."
    ansible-galaxy collection install community-ollama-*.tar.gz --force
fi

echo
echo "🎉 Установка завершена!"
echo
echo "📚 Документация:"
echo "   - Основная: README.md"
echo "   - Роль: roles/ollama/README.md" 
echo "   - Тестирование: molecule/README.md"
echo
echo "🚀 Примеры использования:"
echo "   - Базовое: examples/playbooks/basic-deployment.yml"
echo "   - GPU: examples/playbooks/gpu-deployment.yml"
echo "   - Inventory: examples/inventory.ini"
echo
echo "🧪 Запуск тестов:"
echo "   molecule test                # Docker тесты"
echo "   molecule test -s proxmox    # Proxmox тесты"
echo