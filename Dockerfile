FROM debian:11-slim

RUN apt-get update && \
    apt-get install -y curl sudo wget netcat-openbsd

# Установка 9Hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=1G

# Копируем конфиги ПРИ СБОРКЕ
RUN wget -q -O /tmp/main.tar.gz https://github.com/goluder/goluder/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/goluder-main/config/* /home/_9hits/9hitsv3-linux64/ && \
    rm -rf /tmp/main.tar.gz /tmp/goluder-main

EXPOSE 8000

CMD bash -c " \
    # HEALTH CHECK
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p 8000 -q 0 -w 1; done & \
    \
    # ПРОВЕРКА ПЕРЕД ЗАПУСКОМ
    echo '=== Проверка перед запуском ===' && \
    ls -la /home/_9hits/9hitsv3-linux64/ && \
    echo 'Конфиги на месте:' && \
    ls -la /home/_9hits/9hitsv3-linux64/config/ 2>/dev/null | head -5 && \
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
    --headless 2>&1 | tee /tmp/9hits.log & \
    \
    # МОНИТОРИНГ ПРОЦЕССА
    echo 'Ожидаю 30 секунд и проверяю процесс...' && \
    sleep 30 && \
    echo '=== Проверка процессов ===' && \
    ps aux | grep -i 9hit && \
    echo '=== Логи 9Hits (последние 10 строк) ===' && \
    tail -10 /tmp/9hits.log 2>/dev/null || echo 'Логи еще не созданы' && \
    \
    echo '=== Готово ===' && \
    tail -f /dev/null \
"
