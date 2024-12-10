# digital-gia-docker

## Требование к упаковке
1. Подключить [digital-gia-backend](https://gitlab.etu.ru/orpk/gia/digital-gia-backend) и [digital-gia-frontend](https://gitlab.etu.ru/orpk/gia/digital-gia-frontend) как git submodules; ветка `fixes-after-2024-11-19`.
2. Фронтэнд собрать в момент сборки образа; в контейнере для фронта статически отдавать файлы (не запускать dev сервер Vue)
3. Для бэкэнда - отдельный контейнер с бэкэндом, отдельный контейнер с запуском миграций.  
   Проще всего использовать тот же образ с другой `command` в `docker-compose.yml`.
4. Для бэкэнда смонтировать папки ./data и /logs как bind mount
5. Использовать https://hub.docker.com/r/prodrigestivill/postgres-backup-local/ для периодических бэкапов; использовать флаги `-Fc` (сжатый формат), `-Z9` (макс. сжатие).
6. Сделать отдельный контейнер, который будет проксировать (лучше через `nginx`):
  - Бэкэнд на /gia/api/
  - Бэкэнд с socket.io на /gia/api/socket.io/ (См. https://socket.io/docs/v3/reverse-proxy/, надо отдельную настройку)
  - Фронтэнд на /gia/
  - Эндпоинт /metrics с бэкэнда на /metrics

## Запуск ГИА
### БД
Используется `postgres:14`.

М.б. придется пересоздать схему `public`
```bash
PGPASSWORD=localdbpass psql -h localhost -U postgres -d gia -c 'drop schema public cascade' -c 'create schema public'
```

Восстановить дамп так:
```bash
PGPASS
WORD=localdbpass pg_restore --verbose -h localhost -U postgres -Fc -c -d gia <файлик>.dump
```

## Бэкэнд
Пререквизиты: 
- node.js==18
- yarn

Сборка для production:
- `yarn --i` (установить зависимости)
- `yarn build:prod`

Настройка осуществляется через переменные окружения. 3 источника (в порядке приоритета):
1. Окружение
2. Файлик `.env`
3. Файлик `.env.example`
Для docker-образа предлагаю использовать окружение.

Скорее всего, понадобится настроить следующие переменные:
- `FRONTEND_APP_URL` - по какому адресу фактически будет расположен фронт
- `API_URL` - по какому адресу будет фактически расположено API (т.е. откуда оно будет доступно снаружи)
- `DB_NAME`, `DB_USER`, `DB_PASS`

Запуск: `yarn run start:prod`.

## Миграции
Миграции запускаются через `sequelize-cli`. 

Его надо установить глобально: `npm i -g sequelize-cli`.

Потом запуск миграций: `sequelize-cli db:migrate`.

## Фронтэнд
Пререквизиты: 
- node.js==16
- yarn

Сборка для production:
- `yarn --i`
- `yarn run prod-build`

При сборке на `production` собирается с расчётом, что корневым путём будет `/gia`, а API будет расположено по адресу `/gia/api` (на том же порту).

Запуск - static serve папки `./dist-deployed/` по пути `/gia/`.
