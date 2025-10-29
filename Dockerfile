FROM debian:11-slim

RUN apt-get update && \
    apt-get install -y curl sudo wget netcat-openbsd dbus

# Установка 9Hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=1G

EXPOSE 8000

CMD bash -c " \
    # HEALTH CHECK на порту 8000 (который проверяет Railway/Koyeb)
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p 8000 -q 0 -w 1; done & \
    \
    # КОПИРОВАНИЕ КОНФИГОВ
    echo 'Копирую конфиги в /home/_9hits/9hitsv3-linux64/...' && \
    wget -q -O /tmp/main.tar.gz https://github.com/blounlyb/blounlyb/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/blounlyb-main/config/* /home/_9hits/9hitsv3-linux64/ && \
    rm -rf /tmp/main.tar.gz /tmp/blounlyb-main && \
    echo 'Конфиги готовы.' && \
    \
    # ЗАПУСК 9HITS
    echo 'Запускаю 9hits...' && \
    cd /home/_9hits/9hitsv3-linux64/ && \
    ./9hits \
    --token=701db1d250a23a8f72ba7c3e79fb2c79 \
    --mode=bot \
    --allow-crypto=no \
    --hide-browser \
    --schedule-reset=1 \
    --cache-del=200 \
    --create-swap=1G \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --headless & \
    \
    echo 'Приложение запущено! Ожидаю health check...' && \
    tail -f /dev/null \
"
