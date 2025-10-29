FROM debian:11-slim

# Обновление и установка зависимостей
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    bzip2 \
    libcanberra-gtk-module \
    libxss1 \
    sed \
    tar \
    libxtst6 \
    libnss3 \
    wget \
    psmisc \
    bc \
    libgtk-3-0 \
    libgbm-dev \
    libatspi2.0-0 \
    libatomic1 \
    curl \
    sudo \
    ca-certificates \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Создаем пользователя и настраиваем окружение
RUN useradd -m -s /bin/bash appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Переключаемся на пользователя
USER appuser
WORKDIR /home/appuser

# Установка 9Hits (ВАЖНО: меняем токен!)
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200 --create-swap=1G

# Возвращаемся к root для финальной настройки
USER root

# Создаем директорию для конфигов
RUN mkdir -p /etc/9hitsv3-linux64/config/

# Открываем порт
EXPOSE 10000

# Команда запуска с HEALTH CHECK и копированием конфигов
CMD bash -c " \
    # --- ШАГ А: НЕМЕДЛЕННЫЙ ЗАПУСК HEALTH CHECK ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p 10000 -q 0 -w 1; done & \
    \
    # --- ШАГ Б: КОПИРОВАНИЕ КОНФИГОВ --- \
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/blounlyb/blounlyb/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/blounlyb-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/blounlyb-main && \
    echo 'Копирование конфигурации завершено.' && \
    \
    # --- ШАГ В: ЗАПУСК ОСНОВНОГО ПРИЛОЖЕНИЯ --- \
    sudo -u appuser /home/appuser/9Hits/9HitsApp --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200 --create-swap=1G --no-sandbox --disable-dev-shm-usage --disable-gpu --headless & \
    \
    # --- ШАГ Г: УДЕРЖАНИЕ КОНТЕЙНЕРА --- \
    tail -f /dev/null \
"
