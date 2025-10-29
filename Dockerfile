FROM debian:11-slim

RUN apt-get update && \
    apt-get install -y curl sudo wget netcat-openbsd file

# Установка 9Hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=1G

# ОТЛАДКА: ищем ВСЕ исполняемые файлы 9Hits
RUN echo "=== Поиск всех файлов 9Hits ===" && \
    find / -name "*9hit*" -type f 2>/dev/null | head -20 && \
    echo "=== Исполняемые файлы ===" && \
    find / -name "*9hit*" -type f -executable 2>/dev/null && \
    echo "=== Содержимое домашних директорий ===" && \
    ls -la /home/ /root/ 2>/dev/null && \
    echo "=== Проверка установки ===" && \
    find /home -type f -name "*" 2>/dev/null | grep -i hit

EXPOSE 10000

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
    # ЗАПУСК: попробуем разные варианты
    echo 'Пробую разные пути запуска...' && \
    ( /home/_9hits/9hitsv3-linux64/9HitsApp --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --hide-browser & ) || \
    ( /home/_9hits/9hits-linux-x64/9hits --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --hide-browser & ) || \
    ( /home/_9hits/9hits --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --hide-browser & ) || \
    ( /9hits --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --hide-browser & ) || \
    echo 'Не удалось найти исполняемый файл' && \
    \
    tail -f /dev/null \
"
