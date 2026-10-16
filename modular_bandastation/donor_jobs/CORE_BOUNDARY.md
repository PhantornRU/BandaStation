# Граница PR11 с ядром

База сравнения — `820de7f6ef9235d8417250cb01eec15da6735b18`. Критерий сопровождения: у публичной операции одна исполняемая последовательность, у модульной фазы есть реальный caller. Количество сохранённых строк не доказывает совместимость с upstream. Прежние продолжения и полностью заменяющие native overrides удалены, даже когда это увеличивает красный diff.

`tgstation.dme` включает `modular_bandastation/modular_bandastation.dme`; `_jobs.dme`, `_job_slots_preferences.dme`, `_dynamic.dme`, `_donor_jobs.dme` подключают своих владельцев. Include-инспектор показывает текстовые включения; компиляция проверяет итоговое дерево.

## Исполняемые контракты

| Операция | Единственный маршрут | Модульная фаза |
| --- | --- | --- |
| Допуск профессии | `SSjob.check_job_eligibility`: mind/account/playtime/ban → проверка прежних requester/mind → `check_character_eligibility` | Проверка назначенного профиля с явным `latejoin`; общие проверки и SQL не копируются. |
| Назначение | Native `assign_role` → `prepare_job_assignment` → штатный счётчик и role assignment | Профиль, gate и окончательная вместимость проверяются до изменения вакансии. `is_debug_dummy` разрешён только явно созданному admin dummy. |
| Создание тела | Native `create_character`: подготовка профиля → единственный job constructor → проверка захваченного mind/job/selection → штатный mind transfer | `prepare_character_profile` и `validate_created_character`; проверка охватывает специализированные constructors. |
| Поздний вход | Native `AttemptLateSpawn`: запрос → допуск → arrivals wait → повторный допуск → назначение → создание → handover → экипировка и учёт | Узкие begin/validate/cancel hooks. Нет `finish_latejoin_spawn`, копии orchestration или недостижимой старой прелюдии. |
| Roundstart | Native ticker: construction → `validate_roundstart_character` → collect/equip/handover/joined list | Отказ отменяет queued Dynamic и только своё назначение до экипирования. |
| Экипировка | Native `dress_up_as_job` выбирает outfit через `get_spawn_outfit` и выполняет штатный цикл один раз | Shared variants выбирают комплект; `equip_backpack_item` меняет одну операцию storage. Обычный outfit сохраняет `del_on_fail`. |
| Приветствие | Native mind setter → единственный `get_spawn_message(body)` | Расширяются данные через `get_spawn_message_information(body)`, выбор берётся с созданного тела. |
| Меню | Native `ui_act`: parent/status/client/type guards → один switch | Только `select_job` вызывает `handle_job_selection`. Нет второго dispatcher или общего module `ui_act`. |
| Цвет | Native preferences `ui_act` сохраняет auth/signal/switch → `set_character_color` | Одна guarded modal operation в preferences-модуле, проверка клиента/слота после ожидания. Старый modal body удалён. |
| Manifest | Native inject создаёт запись, сохраняет точную ссылку и вызывает callback только при `initial_job_record` | Общий job callback передаёт конкретный record; смена личности не повторяет первоначальные эффекты. |

### Состояние, переживающее ожидание

Lobby владеет `assigned_character` до успешной передачи. Возврат вакансии требует совпадения захваченных selection и mind; отказ старой попытки не отменяет новую. AI constructor переносит mind раньше остальных constructors: общий `rollback_spawn_character` возвращает только собственный mind при совпадении тела, роли и свободного lobby. После handover отключение клиента сохраняет созданное тело.

`/datum/latejoin_profile_snapshot` хранит preferences identity, editing slot, копию назначений и toggle. Меню сравнивает всю карту, попытка — выбранную профессию. Это снимок маршрутизации, а не заморозка всего содержимого профиля. История слота пишется после успешного native handover.

Dynamic `prepare_job_constraints` выполняет обе исходные операции: `prepare_for_role` и blacklist. `/datum/roundstart_job_changes` хранит добавленные ограничения и прежнее forced assignment. Отмена сохраняет preexisting и независимые последующие изменения. Штатный queued selection запрещает назначать один mind двум roundstart rulesets. Native set не хранит provenance одинаковых blacklist values; произвольное перекрытие одинаковых значений с обходом queued selection не объявляется поддержанным reference counting.

### Общие предпосылки

Эти изменения действуют и при выключенных donor flags; выключение feature не возвращает прежние ошибки:

- Единый `pref_job_slots` и безопасность профиля после ожиданий. Перед реальным запуском обязательна [offline migration/readiness](../../tools/migrate_job_slots/README.md); наличие скрипта не доказывает подключение production-службы.
- Prisoner: crime выбирается один раз в подготовке тела. Единственный native `post_equip` применяет татуировки по этому выбору; exact-record callback добавляет crime/memory/photo один раз. Старый глобальный join handler и отключающий его `New` удалены; concrete ancestor bypass отсутствует.
- ID access: единственный native алгоритм добавляет обычные/wildcard/RETA доступы; отсутствующий bank account только пропускает запись `account_job`. Модульная копия алгоритма удалена.
- AI проверяет client после yielding name lookup; after-latejoin signal допускает отсутствие клиента перед overlay. PDA освобождает свой stale inserted-item reference; quirk handover и color modal проверяют срок жизни своего клиента. Эти исправления принадлежат своим подсистемам.

## Владельцы

| Модуль | Ответственность |
| --- | --- |
| `jobs` | Общие job hooks, admission, orchestration policy, initial record, Prisoner lifecycle, нейтральные `job_variant`/`job_variant_context`, outfit supplies и бесплатный Deliverer. |
| `job_slots_preferences` | Единственное хранение назначений слотов, выбор/загрузка профиля, typed snapshots и профильный middleware. |
| `donor_jobs` | Subscription tiers/gate, объявления платных jobs, их outfits/items, локальные translations, station-trait integration и ID templates. |
| `dynamic` | Candidacy по назначенному профилю, отменяемая подготовка и фактический Blood Worm host. |
| `preferences`, `quirks`, `objects` | Общие color, handover и PDA fixes. |

В TGUI shared `JobLabel`, `JobHudIcon` и DTO находятся в `bandastation/jobs`; tabs/tiers/layout — в `bandastation/donor_jobs`. Static latejoin metadata описывает потенциальные jobs, dynamic rows определяют актуальное присутствие и доступность. Static merge не восстанавливает скрытую вакансию. `availability` — вычисленный код для логики; `unavailable_reason` — отображаемый текст. Второй SQL-запрос ради кода не выполняется.

## Совместимость и удалённые пути

Canonical job titles, job-ban keys, access, balance, config tags и DMI states сохранены. Новые внутренние typepaths и basenames уточняют назначение; Security Clown outfit объявлен как `/datum/outfit/job/clown/security` и наследует штатного clown. HONK capacity subtype остаётся: обычная cell имеет другой заряд, а штатная 1000-charge wiremod cell также EMP-proof и не является эквивалентом.

Все 129 прежних non-default variant IDs переводятся при десериализации `job_outfit_variants`; [полная таблица](../jobs/VARIANT_MIGRATION.md). Resolver не содержит параллельного legacy выбора. Разные публичные названия с одним outfit сохранены. Внутреннее `musician` исправлено, существующий config tag `DONOR_MUSICAN` сохранён.

Удалены `create_character_body`, `finish_latejoin_spawn`, `handle_native_ui_action`, `uses_dynamic_job_visibility`, `get_character_spawn_message`, `get_extended_job_unavailable_error_message`, unused TGUI factory/cache и legacy runtime actions/field. Offline migration продолжает знать старый save key. Дополнительный formatter обрабатывает только два новых кода и возвращает null; native fallback на generic message остаётся явным.

## Файлы core с отличиями от базы

Полный список ниже генерируется из текущего diff к базе. Он показывает реальную стоимость интеграции, включая удаления заменённых алгоритмов. Новая логика находится в модулях; фазовые вызовы и общие исправления требуют review при upstream-изменениях.

- `code/controllers/subsystem/dynamic/_dynamic_ruleset.dm`
- `code/controllers/subsystem/dynamic/dynamic_ruleset_roundstart.dm`
- `code/controllers/subsystem/job.dm`
- `code/controllers/subsystem/networks/id_access.dm`
- `code/controllers/subsystem/ticker.dm`
- `code/datums/mind/_mind.dm`
- `code/datums/outfit.dm`
- `code/datums/records/manifest.dm`
- `code/modules/admin/admin_verbs.dm`
- `code/modules/client/preferences.dm`
- `code/modules/client/preferences/middleware/jobs.dm`
- `code/modules/client/preferences_savefile.dm`
- `code/modules/jobs/job_types/_job.dm`
- `code/modules/jobs/job_types/prisoner.dm`
- `code/modules/mob/dead/new_player/latejoin_menu.dm`
- `code/modules/mob/dead/new_player/new_player.dm`

## Проверка

Production build, external DM overlay/runtime, TGUI types/lint, browser fixture и реальный BYOND-клиент — разные проверки. Внешний regression source закрепляется отдельно от feature PR и запускается в TEMP worktree. Четыре сочетания flags проверяют независимость donor jobs и Prisoner gate. Проверенное дерево и результаты указываются в актуальном описании PR; исторические результаты не переносятся автоматически.

Headless fixtures не доказывают подключение настоящего клиента, вид игровых модальных окон или расстановку landmarks на игровых DMM. Production launcher/save root проверяются отдельно; реальные saves этой задачей не изменяются.
