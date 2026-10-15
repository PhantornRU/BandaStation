# Граница PR11 с ядром

Сравнение ведётся с базой PR `820de7f6ef9235d8417250cb01eec15da6735b18`. Перед этой чисткой (`a4bea76ffe9540d21f1865e5fb56ed4bcb3a6920`) в `code/` были затронуты 19 файлов и 396 строк, в том числе 10 файлов и 344 строки в `code/modules/`. Строки считаются как additions + deletions из `git diff --numstat`, а не как размер процедур.

После повторной чистки в `code/modules/` остаются 4 файла и 23 строки: `new_player.dm` — 11 вместо 121, `latejoin_menu.dm` — 6 вместо 118. Во всём `code/` остаются 9 файлов и 46 строк. Первый опубликованный результат `b135fcb` оставлял 11/50; независимая проверка дополнительно вернула два native-файла. Добавления модульной логики не входят в эти показатели.

Подключение остаётся штатным: `tgstation.dme` → `modular_bandastation/modular_bandastation.dme`, который включает `_donor_jobs.dme`, `_job_slots_preferences.dme`, `_jobs.dme` в этом порядке. Новый `jobs/code/native_job_extensions.dm` включён в `_jobs.dme`; остальные дополнения находятся в уже подключённых файлах. Макросы новых сигналов и кодов отказа принадлежат `_defines220`.

## Все оставшиеся изменения в code/modules

| Файл | Diff к базе | Точка входа и причина |
| --- | --- | --- |
| `code/modules/admin/admin_verbs.dm` | +1/−1 | Явный `is_debug_dummy = TRUE` для штатных admin dummies. Модуль не должен считать любого игрока без клиента разрешённым обходом допуска. |
| `code/modules/client/preferences_savefile.dm` | +2/−2 | Два вызова: загрузка и сохранение модульного формата в штатных фазах I/O. Загрузка выполняется до `check_keybindings()`, способного сохранить настройки. Нет глобального перехвата JSON I/O. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm` | +5/−1 | Захват клиента и guard после yielding admission; модульный predicate для статических метаданных; один заголовок `handle_native_ui_action()` после исходного вызова UI parent. Модуль начинает с `. = ..()`, проверяет authorization и обрабатывает `select_job`; остальные действия передаёт сохранённому native switch. Проверка отсутствующего клиента выполняется до native `ui_data()`, сам parent строит динамические строки один раз. |
| `code/modules/mob/dead/new_player/new_player.dm` | +6/−5 | Два заголовка продолжений (`create_character_body`, `finish_latejoin_spawn`), проверка готового тела до mind transfer, exact-record флаг, module fallback кодов отказа и защита клиента после передачи тела. Прежняя запись истории при конструировании удалена: модуль записывает выбранный слот после handover. Сам `transfer_character()` полностью восстановлен; алгоритмы конструирования, оснащения и дальнейшего учёта сохранены в исходном файле. |

## Остальные врезки code

| Файл | Diff к базе | Почему остаётся |
| --- | --- | --- |
| `code/controllers/subsystem/dynamic/_dynamic_ruleset.dm` | +1/−2 | `prepare_job_assignment()` объединяет штатную подготовку и blacklist в отменяемую фазу. `prepare_execution()` помечен `SHOULD_NOT_OVERRIDE`; перенос всей процедуры в модуль потребовал бы копирования алгоритма Dynamic. |
| `code/controllers/subsystem/job.dm` | +3/−1 | Один alternate eligibility call в штатном random loop и граница после account-age/playtime/jobban: успех parent и заголовок `check_current_character_eligibility()` перед исходной проверкой текущего персонажа. Сигнатура и исходный хвост сохранены; старый хвост выделен в самостоятельную процедуру, чтобы избежать недостижимого кода. Модульный wrapper вызывает native parent с четырьмя аргументами один раз, сохраняет его отказы, проверяет requester после SQL и применяет selected-profile admission; `latejoin` принадлежит wrapper. |
| `code/controllers/subsystem/ticker.dm` | +3/−3 | Проверка/отмена результата roundstart construction до оснащения и записи участника. Коллекции, оснащение и handover остаются у ticker. |
| `code/datums/outfit.dm` | +1/−1 | `equip_backpack_item()` в существующем storage loop: обычный outfit сохраняет штатную операцию, donor outfit обрабатывает переполнение. |
| `code/datums/records/manifest.dm` | +5/−3 | Флаг первоначального спавна и callback с конкретным только что созданным crew record. Обычная повторная инъекция manifest при смене личности не повторяет Prisoner effects. |

## Что полностью возвращено

Эти файлы побайтно совпадают с базой PR после данной чистки:

| Файл | Куда перенесено поведение |
| --- | --- |
| `code/modules/jobs/job_types/_job.dm` | Короткие construction/equipment/AI preference/latejoin/greeting расширения в `jobs/code/native_job_extensions.dm`; метаданные и outfit hooks в `jobs/code/extension_hooks.dm`. |
| `code/modules/jobs/job_types/prisoner.dm` | `jobs/code/job_types/prisoner/spawn.dm` и exact-record adapter `jobs/code/records.dm`. |
| `code/modules/client/preferences/middleware/jobs.dm` | `job_slots_preferences/code/pref_job_slots_middleware.dm`: parent constructor, отключение старого action, postprocessing штатных priority rows. |
| `code/modules/client/preferences/middleware/names.dm` | `donor_jobs/code/preferences/clown_name.dm`: специальное имя Клоуна СБ и родительский выбор для остальных профессий. |
| `code/modules/shuttle/mobile_port/variants/arrivals.dm` | Короткий `wait_for_latejoin_player()` в `jobs/code/player/latejoin.dm`, отменяемый при исчезновении исходного игрока. Штатный `RequireUndocked()` сохранён. |
| `code/__DEFINES/jobs.dm` | Два модульных кода отказа в `_defines220/code/defines/jobs.dm`. |
| `code/modules/client/preferences.dm` | `job_slots_preferences/code/job_slots_preferences.dm`: модульный `ui_act()` перехватывает только color action, вызывает конкретный `/datum::ui_act()` для штатного signal/status, затем guarded modal helper. Остальные действия идут через `..()`. |
| `code/controllers/subsystem/dynamic/dynamic_ruleset_roundstart.dm` | `dynamic/code/blood_worm.dm`: override Blood Worm вызывает конкретный roundstart ancestor для общих проверок и модульный selected-profile predicate. Исходный subtype species-фильтр не запускается. |
| `code/datums/mind/_mind.dm` | `jobs/code/native_job_extensions.dm`: короткий greeting entrypoint назначает роль один раз, сохраняет проверку смены роли и передаёт созданное тело в модульные инструкции. Native final formatter сохранён. |
| `code/controllers/subsystem/networks/id_access.dm` | Модульный adapter отдельно обслуживает job-template карту без банковского счёта; остальные карты идут через `..()`. Сохраняются очистка, обычные доступы, wildcard-доступы и активные RETA grants. Новая пустая ID обычно уже имеет штатный счёт; исключение относится к реально отсутствующему `registered_account`. |

Уже возвращённые ранее файлы также не входят в diff PR: `.github/workflows/run_linters.yml`, `code/__DEFINES/dcs/signals/signals_mob/signals_mob_carbon.dm`, `code/__DEFINES/dcs/signals/signals_mind.dm`, `code/controllers/subsystem/processing/quirks.dm`, `code/modules/client/preferences/names.dm`, `code/modules/mob/dead/new_player/logout.dm`.

`config/game_options.txt` полностью восстановлен: opt-in переключатели объявлены в модуле и описаны в README. В `config/jobconfig.toml` остаются только 22 пустые секции (+23 строки): наличие секции предотвращает штатное предупреждение об отсутствующей конфигурации, значения берутся из job datums. Подробные шаблоны вынесены в [jobconfig.example.toml](jobconfig.example.toml); их ключи `"# ..."` не применяются parser до снятия префикса. Существующие секции и все читаемые загрузчиком значения сохранены. Changelog остаётся в штатном каталоге.

## TGUI и остальные пути вне модулей

Независимая проверка охватывает весь PR: статистика `code/` не включает TypeScript, стили и конфиги. Native TGUI сократился с 5 файлов / 254 строк в `b135fcb` до 4 / 171. `styles/interfaces/PreferencesMenu.scss` полностью восстановлен; модульный `JobHudIcon` статически импортирует неизменённый модульный SCSS, используя штатный Rspack CSS pipeline.

| Native TGUI файл | Diff к базе | Оставшая интеграция |
| --- | --- | --- |
| `interfaces/PreferencesMenu/CharacterPreferences/JobsPage.tsx` | +56/−26 | Импорты модульных label/restriction/filter/layout и priority hook; один исходный `JobRow` обслуживает обе вкладки. `JobsLayout` владеет provider, `JobsSection` — tier list. Исходные три колонки и старая фабрика priority callbacks восстановлены; активный caller использует hook, захватывающий слот отрисованной строки. |
| `interfaces/PreferencesMenu/CharacterPreferences/JobSlotDropdown.tsx` | +16/−8 | Канонические `pref_job_slots`, действие `set_job_slot`, `edit_slot` и описание выбранного профиля. Отдельная копия штатного виджета ради удаления этого diff не создаётся. |
| `interfaces/PreferencesMenu/types.ts` | +6/−2 | Типы канонического протокола профилей. |
| `interfaces/JobSelection.tsx` | +32/−25 | Модульное объединение static metadata с authoritative dynamic vacancies, отображение профиля/варианта и отправка render-slot. Скрытые dynamic вакансии не восстанавливаются из static данных. |

В сумме native DM и TGUI содержат 217 затронутых строк вместо 304 в первом опубликованном результате. Это показатель границы с ядром; новые модульные файлы и конфигурационные данные считаются отдельно.

`tools/migrate_job_slots/` — новый самостоятельный offline CLI, а не переделка существующего инструмента. Он нужен для перехода на единственное runtime-хранилище и не вызывается игрой. Данные конфигурации и changelog используют штатные каталоги. Изменений workflow, карт и native assets в diff PR нет.

## Активный путь и сохранённый исходный код

1. Preferences загружают только `pref_job_slots`; legacy `job_assigned_profiles` не читается из сохранений и очищается модульными load/save hooks. При сохранении старый ключ удаляется. Offline-конвертация выполняется отдельным инструментом.
2. Native jobs middleware остаётся в исходнике, но модульный constructor удаляет `set_job_to_profile` из dispatch; прямой вызов его модульного override возвращает `FALSE`. Postprocessing исключает legacy UI fields и строки без приоритета.
3. Модульный `AttemptLateSpawn()` выполняет admission, повторную проверку после SQL/шаттла, назначение и handover. Он вызывает native `finish_latejoin_spawn()` ровно один раз после успеха. Старый native prelude не вызывается через `..()`.
4. Модульный `create_character()` фиксирует и загружает выбранный профиль, затем вызывает native `create_character_body()`. Его старый prelude с `job_assigned_profiles` не вызывается. Общая проверка готового тела действует и для специализированных `get_spawn_mob()`, обходящих базового родителя. Она сверяет preferences, слот, профессию, ограничения и фактическое тело до передачи mind; AI rollback возвращает уже перенесённый mind при отказе.
5. Модульный `transfer_character()` сохраняет connection и выбранный слот в локальных переменных, вызывает `. = ..()` и при успешном результате записывает слот однократно. Native possession и удаление lobby остаются штатными; запись работает также при самостоятельной offline-передаче и connection, уже перенесённом на AI-тело. После родительского вызова модуль не читает удалённый lobby/selection. Отказ освобождает только подготовленную вакансию и снимает Dynamic callbacks.
6. Модульный random helper проверяет explicit preference до и после yielding eligibility. Случайный выбор не превращается в обход явно отключённой донорской профессии.
7. Prisoner `New()` вызывает родителя, затем снимает раннюю global подписку. Модульный `post_equip()` вызывает конкретного общего предка job-outfit один раз, обходя исходный Prisoner handler, который повторно выбирал преступление. Запись и татуировки используют один выбор тела.
8. Color и `select_job` имеют модульные `ui_act()` entrypoints. Color вызывает конкретный `/datum::ui_act()` для единственного `COMSIG_UI_ACT` и штатной проверки статуса. Latejoin начинает с обычного `. = ..()`: native `ui_act()` вызывает generic authorization, а новый заголовок продолжения отделяет от него исходные guard/switch. Модуль уважает отказ, обрабатывает `select_job` и передаёт прочие действия в `handle_native_ui_action()`. Даже изменение статуса из signal listener останавливает dispatch до продолжения; signal остаётся однократным. Старые color/select ветки switch не достигаются на активном UI-пути. Native middleware не подходит для перехвата: delegation выполняется после switch.
9. Blood Worm вызывает конкретный `/datum/dynamic_ruleset/roundstart::is_valid_candidate()`, включая модульный roundstart wrapper и исходные общие проверки. Затем проверяется выбранный профиль. `SHOULD_CALL_PARENT(FALSE)` локально объявляет эту замену subtype: DreamChecker 1.11 распознаёт только `..()`, хотя общий предок фактически вызывается.
10. Короткий `after_latejoin_spawn()` целиком заменён модулем: он один раз отправляет исходный global signal и затем проверяет nullable client перед overlay. `SHOULD_CALL_PARENT(FALSE)` явно объявляет замену: вызов прежнего двухоперационного parent повторил бы signal либо разыменовал отключившийся client. Это локальное исключение также требует review наследников при upstream-изменениях.

### Почему оставшиеся врезки нельзя заменить внешним wrapper

- Preferences load вызывает `check_keybindings()`, а тот сохраняет preferences ещё до возвращения из load. Поэтому post-load hook уже поздний. Native save самостоятельно записывает legacy-ключ перед I/O: нужна точка именно в фазе сериализации.
- Latejoin `ui_data()` проверяет много профессий в одном цикле. Проверка клиента только после всего parent не останавливает следующий проход после yielding SQL/disconnect. Статический фильтр способен заранее удалить метаданные скрытой вакансии; predicate сохраняет их для последующего динамического открытия без второго SQL-обхода.
- Один заголовок `handle_native_ui_action()` сохраняет исходный switch и позволяет модулю проверить результат UI parent до побочных эффектов. Один лишь wrapper вокруг прежнего цельного `ui_act()` не мог остановить native действия после отказа: исходник не проверял результат `. = ..()`.
- `create_character_body()` и `finish_latejoin_spawn()` — два заголовка продолжений исходных алгоритмов. Они позволяют модулю заменить profile/admission prelude, не копируя оснащение, manifest, arrivals и construction. Проверка готового тела должна сработать до mind transfer, включая специализированные constructors. Старую запись истории при создании тела убрали: она выполнялась до успешного handover; native `transfer_character()` остаётся исходным.
- Explicit admin dummy flag устанавливает источник обхода. Ни отсутствие клиента, ни общий mob/mind signal не отличает этот источник от обычного disconnect.
- Global `get_job_unavailable_error_message()` нельзя переопределить через same-type `..()`: pinned BYOND 516.1685 отклоняет повторный `/proc/`, а `/name()` не переопределяет глобальный proc. Остаётся один fallback-вызов.

Уменьшение этих точек за счёт копии большого native цикла, временной подмены общих preferences или глобального JSON-перехвата увеличило бы зависимость от upstream. Такие варианты не используются.

Вызов `..()` используется там, где штатный путь сохраняет нужный порядок и побочные эффекты. Там, где прежний prelude применяет текущий слот, старое хранилище или ранний callback, модуль владеет альтернативным входом. Большие native тела остаются единственными реализациями в ядре; короткие overrides и конкретные ancestor calls требуют проверки при изменениях upstream, в том числе добавлении prelude перед исходным action switch.

## Проверка границы

Сравнивать следует весь PR с указанной базой, а не только текущий рабочий diff. Обязательны штатный production build, отдельная компиляция внешнего тестового overlay и runtime fixtures при включённых/выключенных donor flags. Fixtures проверяют недостижимость legacy action/storage, однократность эффектов, SQL-shaped смену контекста, отмену вакансии, dispatch к сохранённому продолжению и допуск специализированного тела.

Headless runtime не подтверждает реальный BYOND UI, подключение клиента, визуальное оснащение и расстановку landmarks на рабочих картах. Эти проверки выполняются отдельно в клиенте; compilation и fixtures не подменяют их.
