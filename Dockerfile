FROM debian:11-slim

# 1. Установка всех утилит и зависимостей
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget tar netcat bash curl sudo bzip2 psmisc bc \
    libcanberra-gtk-module libxss1 sed libxtst6 libnss3 libgtk-3-0 \
    libgbm-dev libatspi2.0-0 libatomic1 && \
    rm -rf /var/lib/apt/lists/*

# 2. Установка 9Hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200 --create-swap=10G

# 3. Создаем симлинк /nh.sh
RUN ln -s /home/_9hits/9hitsv3-linux64/9hits /nh.sh

# 4. Установка порта (ВОЗВРАЩАЕМ 10000!)
ENV PORT 10000
EXPOSE 10000

# 5. КОМАНДА ЗАПУСКА
CMD bash -c " \
    # --- ШАГ А: НЕМЕДЛЕННЫЙ ЗАПУСК HEALTH CHECK на порту 10000 ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p \${PORT} -q 0 -w 1; done & \
    # --- ШАГ Б: ЗАПУСК ОСНОВНОГО ПРИЛОЖЕНИЯ ---
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --session-note=goluder --note=goluder --hide-browser --cache-del=200 --create-swap=10G --no-sandbox --disable-dev-shm-usage --disable-gpu --headless & \
    sleep 70; \
    # --- ШАГ В: КОПИРОВАНИЕ КОНФИГОВ ---
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/goluder/goluder/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/goluder-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/goluder-main && \
    echo 'Копирование конфигурации завершено.'; \
    # --- ШАГ Г: УДЕРЖАНИЕ КОНТЕЙНЕРА ---
    tail -f /dev/null \
"
