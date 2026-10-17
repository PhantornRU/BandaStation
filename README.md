# Внешние регрессионные проверки BandaStation PR11

83 DM-регрессии, 21 Python-тест и 1 Bun-тест. Product commit `5026cbb6221c6b56ba853d7ca5cfcf96e52d23f6`, tree `523188dc324f0c16ac1c5d7111f632090b617c0b`, BASE `820de7f6ef9235d8417250cb01eec15da6735b18`.

Один новый полный `all` PASS после исправления fixtures и найденного hard-delete бага: production `tools/build/build.bat build -Werror` со свежей TGUI, native CIBUILDING без overlay, Python21/21, Bun1/1, внешний DM compile и 83/83 в каждом режиме00/01/10/11. DD exit0, clean_run, runtime errors0. Исполненное дерево `f7c4dacb8abfd7a10abd03411a3ca3976ce6a285`, manifest SHA256 `48fb1726962ffc7ee4140c04c219cae9af1d0a262ef8c3faef6e782a6e96ef59` сохранён как `EXECUTED_MANIFEST.json`.

Перед коммитом удалена ровно одна пустая EOF-строка в character_creation.dm. [POST_TEST_FORMAT.json](POST_TEST_FORMAT.json) доказывает полное совпадение остальных файлов/байтов и связывает исполненное дерево с product tree; runtime ради whitespace не повторялся. `CANONICAL_MANIFEST.json` SHA256 `f8fe97895350a17837854f1987689091295cd1bb84dc31e9f51ed04d02e44526` предназначен для replay опубликованного дерева. В replay изменились только hash этого input, соответствующий hash guard адаптера и metadata; assertions и алгоритмы runner/adapter не менялись. Исполненные версии двух inputs сохранены как `EXECUTED_client_fixture_adapter.py` и `EXECUTED_SOURCE_INPUTS.json`. [VERIFICATION.json](VERIFICATION.json) закрепляет hashes результатов и оба дерева.

Новый context проверяется настоящим public create/native validator при замене assignment, hard-delete lobby, owned/foreign body и reentrancy. Проверка принадлежит живому per-call context: BYOND прерывал native proc удалённого lobby до проверки. Контекст охватывает один вызов исходного job constructor и проверку до возврата; отдельный DM probe и новая регрессия проверяют этот дефект. Старые assertions сохранены. Семь initial() outfit values проверяют настоящее наследование clown. Profile DTO проверяет назначенный B, fallback и ordinary null-title. Source-only fixtures остаются вне feature diff.

Нужны Windows, Git, Python3.11+, BYOND516.1685, Bun1.3.5, Cutterv5.0.1; зависимости — в settings.example.json. Секреты, настройки машины, player saves, бинарники и runtime logs не публикуются.

```powershell
git -c core.autocrlf=true clone https://github.com/PhantornRU/BandaStation.git ../BandaStation
git -C ../BandaStation checkout --detach 5026cbb6221c6b56ba853d7ca5cfcf96e52d23f6
py -3 -B ./run.py --verify-bundle
Copy-Item ./settings.example.json ./settings.json
# Заполните локальные пути зависимостей.
py -3 -B ./run.py --settings ./settings.json --repository ../BandaStation --suite all
```

Все fixture bytes опубликованы как исполненные. Отличия replay metadata/hash guard после EOF-правки перечислены выше; исполненные версии сохранены. Для auto-text inputs используется core.autocrlf=true; explicit eol=lf сохраняется. [Происхождение](provenance.json), [запуск и ограничения](README_RU.md). Native parent источники/проверки не заменены внешними алгоритмами. Точный mock-input adapter используется только в TEMP после unadapted production/native компиляций.

Headless не подтверждает подключённый BYOND client, live SQL, modal YES, localhost notification или sprites. Browser harness и полный native runtime suite не выполнялись. Production launcher/save root не подтверждены; реальные saves не читались и не менялись. Лицензия [AGPLv3](LICENSE).
