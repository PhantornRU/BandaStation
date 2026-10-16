# Воспроизводимые внешние проверки PR11

Этот каталог — отдельный тестовый источник. Его следует публиковать отдельной закреплённой Git revision, а в feature PR оставлять ссылку на revision и SHA256 `manifest.json`. Тестовые файлы не входят в продуктовый PR BandaStation.

## Состав и происхождение

`overlay/` содержит исходный внешний набор из 44 DM-тестов, 21 Python-теста миграции/readiness и 1 Bun-теста, а также согласованные регрессии последующих cleanup-задач. Точные текущие количества и имена записаны в `manifest.json`. `provenance.json` содержит исходные hashes и причины каждого изменения. Исходный baseline не перезаписан. В bundle нет локальных зависимостей, runtime данных, реальных player_saves или `local.json`.

Адаптации сохраняют проверяемое поведение: текущие semantic variant IDs используются как runtime inputs; legacy-ID deserialization проверяется отдельно; удалённые tail/body/dispatcher continuation API не создаются тестами заново. Вместо них проверяются настоящие публичные create/AttemptLateSpawn пути. Native handler и совместимое поле восстановлены: тесты доказывают их наличие, отключение делегации на экземпляре, отклонение прямого вызова и независимость canonical map. Ранние assertion includes используют отдельные поздние helpers только для module-owned числовых кодов/сигнала; копии продуктовой реализации нет.

## Проверка артефакта без сборки

```powershell
py -3 -B ./run.py --verify-bundle
```

Проверяются hashes, полный overlay inventory и уникальные DM test names. Это проверка упаковки; она не является compile/runtime PASS. `SOURCE_INPUTS.json` закрепляет bytes продуктовых inputs и удалённых путей при seal. При запуске runner сравнивает эти inputs с выбранной рабочей копией. HEAD и полный snapshot фактического запуска отдельно записываются в `RESULT.json`.

## Локальная настройка

Скопируйте `settings.example.json` в свой settings-файл и укажите расположение репозитория и зависимостей. Все относительные значения разрешаются **от каталога settings-файла**, а не от cwd или исходной машины автора. Абсолютные пути допустимы только в вашем локальном settings-файле. Пример содержит относительные пути и проверенные hashes Cutter/runtime DLL; сами зависимости не поставляются.

Нужны Windows, Git, Python и версии из `dependencies.sh` проверяемого checkout: BYOND 516.1685, Bun 1.3.5, Cutter v5.0.1. Runtime DLL проверяются побайтно по SHA256 из settings. Их тестовый набор не следует подменять библиотеками production сервера. Штатный bootstrap использует отдельный заданный cache; установка JS dependencies выполняется по lockfiles внутри TEMP checkout.

```powershell
py -3 -B ./run.py --settings ./settings.json --repository ../BandaStation --suite all
```

Для явно разрешённого dirty snapshot добавьте `--include-worktree`. Runner сохраняет tracked binary patch и bytes всех неигнорируемых untracked files. Изменения применяются только в новом detached TEMP worktree; исходный индекс не изменяется. Проверяются точное применение snapshot, а в finally — неизменность HEAD/raw status/patch/untracked bytes исходной копии. Без флага требуется чистый HEAD. Не добавляйте локальные logs/settings в продуктовый checkout.

Можно выбрать `--suite canonical` (production + native compile без overlay), `production`, `native`, `dm`, `python` или `bun`. `--artifacts <directory>` задаёт родительский каталог нового изолированного запуска; по умолчанию используется системный TEMP. Сборка/тесты запускаются только явно, без действий при импорте Python-модуля.

## Что исполняется

`all` выполняет production `tools/build/build.bat build -Werror` до добавления тестов, затем штатную CIBUILDING-компиляцию без overlay. После этого подключает manifest overlay перед штатным `#undef TEST_ASSERT`, поздние helpers и focus только в TEMP DME; выполняет Python/Bun и DM compile. Собранный DMB запускается четырежды на runtimestation_minimal в независимых config/data каталогах:

| Режим | DONOR_JOBS_ENABLED | DONOR_PRISONER_GATE |
| --- | --- | --- |
| 00 | 0 | 0 |
| 01 | 0 | 1 |
| 10 | 1 | 0 |
| 11 | 1 | 1 |

Каждый запуск передаёт отдельные expected flag markers. `donor_configuration` проверяет actual config и начальный pool перед собственными временными переключениями; все прежние policy assertions сохранены. Каждый режим обязан вернуть ровно manifest test names со status0 и clean_run marker. Нельзя смешивать успешные фазы разных source snapshots без явного указания.

После native-проверок `client_fixture_adapter.py` делает строго пять замен (шесть чтений) mock-input в TEMP: profile/history/account age. Проверяются полные source hashes, proc boundaries и exact counts до любых записей. Constructor argument, actual connected-client validation и client consumers не подменяются. Поэтому negative specialized-body тест проверяет отказ, а не успешный вход настоящего клиента. Inventory исходных/адаптированных hashes записывается в RESULT. `native_preservation.py` до overlay проверяет все core-hunks к базе: определения и многострочные блоки сохранены, изменения имеют владельцев и причины.

Единственная средовая правка в TEMP bootstrap — process-specific имя служебного Python log, устраняющее конкуренцию двух генераторов Windows. Проверенный native fake-key lifecycle в priority lifetime fixture находится прямо в reviewed overlay bytes. Source/путь/причина адаптаций сохранены в provenance.

Результаты, логи, source snapshot, compiled artifacts и четыре runtime каталога сохраняются в новом каталоге запуска; `RESULT.json` сообщает все source/bundle hashes и фазовые результаты. Runner не закрывает чужие серверы и не удаляет рабочие копии автоматически.

## Границы доказательства

DM fixtures используют headless/mock client contracts там, где настоящий BYOND client недоступен; это отмечено в исходниках публичных route tests. В respawn policy runtime проверяет helper policy и clientless public AttemptLateSpawn. Штатная ветка `client?.is_localhost()` сохранена относительно базы, но уведомление настоящего localhost-клиента не проверено runtime. Browser replay имеет отдельную инструкцию в `browser/`: настоящие React components и свежий canonical production CSS, synthetic backend. Он не подтверждает BYOND клиент.

Python миграционные/readiness тесты используют временные synthetic saves. Реальный deployment launcher, cwd и save directory неизвестны: production migration/readiness остаётся **UNVERIFIED** до проверки владельцем фактического запуска. Этот bundle не сканирует и не мигрирует настоящие сохранения и не подтверждает readiness службы.
