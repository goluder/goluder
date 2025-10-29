FROM debian:11-slim

# Обновление и установка зависимостей (добавляем sudo)
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

# Создаем пользователя и настраиваем sudo
RUN useradd -m -s /bin/bash appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Устанавливаем 9Hits ТОЧНО как вы привыкли
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=1G

# Создаем директорию для конфигов
RUN mkdir -p /etc/9hitsv3-linux64/config/

EXPOSE 10000

# Команда запуска
CMD bash -c " \
    # HEALTH CHECK
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p 10000 -q 0 -w 1; done & \
    \
    # КОПИРОВАНИЕ КОНФИГОВ
    echo 'Копирую конфиги...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/blounlyb/blounlyb/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/blounlyb-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/blounlyb-main && \
    echo 'Конфиги готовы.' && \
    \
    # ЗАПУСК ПРИЛОЖЕНИЯ (используем стандартный запуск)
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=1G --no-sandbox --disable-dev-shm-usage --disable-gpu --headless & \
    \
    tail -f /dev/null \
"
