# Граница PR11 с ядром

База сравнения — `820de7f6ef9235d8417250cb01eec15da6735b18`. Проверяется весь diff PR, независимо от коммита. Штатные определения и порядок операций сохраняются. Новая политика живёт в `modular_bandastation/`: overrides вызывают настоящего родителя, дополняют результат или собственное состояние. Внутри native процедуры допустим узкий адаптер входного значения либо проверка в момент, недоступный внешнему override.

Предыдущее правило об удалении исходных реализаций ради единственной последовательности отменено. Нельзя переносить штатный алгоритм в модуль, оставлять обрезанную прелюдию или скрывать исходник за безусловным ранним переходом. `. = ..()` не отменяет уже выполненных побочных эффектов; проверки допуска выполняются до назначения, переноса mind и экипировки. `JOB_AVAILABLE` равен нулю, поэтому результат сравнивается с кодом явно.

## Исполняемые маршруты

- **Допуск.** Native `check_job_eligibility` сохраняет mind/account/playtime/ban/age проверки. Модульный wrapper вызывает его один раз, проверяет прежнего requester/mind и правила профиля. В native age-ветку передаётся возраст выбранного профиля. После SQL нельзя обращаться к удалённому lobby/client.
- **Назначение.** Native `assign_role` перед изменением вакансии вызывает `prepare_job_assignment`: окончательные профиль, gate, вместимость и активный latejoin request. Admin-инструмент одной инъекцией отмечает созданный им lobby через модульное состояние `is_admin_job_dummy`; сигнатура и вызов `assign_role` сохранены. Отключившийся игрок исключением не становится.
- **Случайное назначение.** Native `give_random_job` сохраняет прежний `check_job_eligibility` и его `continue`. Отдельный следующий `if/continue` вызывает модульную проверку текущего explicit opt-in; она не выполняет SQL и не заменяет исходный допуск.
- **Приветствие.** Native `set_assigned_role_with_greeting`, `get_spawn_message` и `get_spawn_message_information` полностью сохранены. Модуль вызывает `. = ..()` и затем отправляет только дополнительные инструкции отдельным блоком, учитывая фактическое тело и выбранный вариант. Штатное назначение, форматирование и сообщение не копируются.
- **Создание.** Модульный `create_character` фиксирует и загружает профиль, затем вызывает родителя с выбранным forced slot. Native сохраняет собственные constructor, mind transfer, original slot и запись истории. Внутренняя проверка перед mind/history охватывает также специализированные constructors. Native AI constructor уже перемещает mind; rollback возвращает только захваченный mind из собственного тела.
- **Поздний вход.** `AttemptLateSpawn` сохраняет штатные alerts, arrivals/RequireUndocked, очередь, назначение, телеметрию, создание, handover, экипировку и callbacks. Wrapper владеет typed request и блокировкой повторного запуска. Внутренние проверки после ожидания не выполняют второй SQL. Перед исходным CRASH компенсируется только своё назначение; лишь зафиксированный отказ допуска считается ожидаемым результатом.
- **Меню.** Native `ui_act` сохраняет авторизацию, switch и всю ветку `select_job`, включая round/load/queue/species checks. Модуль адаптирует источник species и выбранный профиль; исходные методы не удаляются. Fallback и random сохраняют родительские циклы и modal; hooks изменяют варианты и проверяют контекст после ожидания.
- **Preferences.** Native action map, handler и построение DTO восстановлены. После родителя модуль копирует карту экземпляра, отключает старую делегацию, преобразует полученные строки DTO. Прямой вызов прежнего handler отклоняется. Сохранённое `job_assigned_profiles` остаётся пустым совместимым полем, не вторым хранилищем и не ссылкой на `pref_job_slots`.
- **I/O.** Native read/sanitize/write сохранены. После legacy read, до возможного вложенного save, модуль загружает независимую canonical map и очищает compatibility field. После native set_entry, до единственного savefile.save(), модуль удаляет старый ключ и записывает canonical. Offline migration обязательна до реального запуска.
- **Prisoner.** Native `New`, global handler и `post_equip` восстановлены. Модуль после родителя снимает свою старую подписку и вызывает настоящий handler с сохранённым преступлением и точной первоначальной записью manifest. Native выполняет crime/memory/photo/tattoos один раз; нет вызова далёкого предка и копии алгоритма.
- **Экипировка.** Native outfit сохраняет исходную storage-операцию с `del_on_fail`. Только outfit с `preserve_backpack_supplies` обрабатывает предмет в модуле и сообщает handled; при переполнении он остаётся у персонажа или рядом. Shared variants меняют источник outfit, а не цикл экипировки.
- **Цвет.** Native auth/signal/switch и color modal сохранены. Две локальные проверки фиксируют editing slot до ожидания и проверяют пользователя/preferences/slot после него. Helper не содержит второй реализации modal.

## Состояние и отмена

`latejoin_profile_snapshot` хранит requester/mind, preferences identity, editing slot, копию назначений и toggle. Меню сравнивает всю карту, попытка — выбранную профессию. Это снимок маршрутизации, а не заморозка всех полей профиля. Состояние не хранится в singleton меню, global job datums или временно подменённых preferences.

Отмена требует совпадения selection, mind и конкретного созданного тела. Она освобождает свою вакансию и свою добавку native history; предшествующая история и чужое назначение сохраняются. После успешного handover созданное тело сохраняется при отключении клиента.

Roundstart захватывает selection до native создания тела. Для ручного назначения без подготовленного selection используется тот же синхронный resolver; удалённый или заменённый selection лишает старую попытку права отменять назначение.

Dynamic сохраняет обе inline native операции `prepare_for_role` и добавление blacklist. Две инъекции снимают состояние до/после них. `roundstart_job_changes` хранит только добавленные блокировки и изменение forced job; отмена сохраняет предшествующие и независимые последующие изменения. Native queued-selection veto действует для того же mind. Произвольное перекрытие одинаковых blacklist значений с обходом штатного выбора не объявляется reference counting.

## Владельцы

| Модуль | Ответственность |
| --- | --- |
| `jobs` | Допуск, lifecycle, initial record, Prisoner, нейтральные variants, outfit supplies и бесплатный Deliverer. |
| `job_slots_preferences` | Единственное хранилище назначений, загрузка профиля, snapshots и middleware. |
| `donor_jobs` | Subscription tiers/gate, собственные jobs, outfits/items, translations и ID templates. |
| `dynamic` | Допуск по назначенному профилю, отмена подготовки и фактический Blood Worm host. |
| `preferences`, `quirks`, `objects` | Проверки modal/handover и освобождение stale PDA reference. |

`tgstation.dme` → `modular_bandastation/modular_bandastation.dme` → module DME → реализации. Текстовый include graph не заменяет компиляцию. Общие fixes ID account, AI после name wait, nullable latejoin client и PDA/quirks действуют независимо от donor flags и обозначаются как предпосылки, а не скрываются за donor gate.

Canonical titles, ban keys, access, баланс, config tags и DMI states сохраняются. Внутренние typepaths и basenames уточнены; Security Clown outfit наследует clown. HONK cell сохраняется из-за отличий заряда/EMP от штатных типов. Все 129 прежних variant IDs переводятся при десериализации, см. [таблицу](../jobs/VARIANT_MIGRATION.md).

## Проверка

Для каждого оставшегося core-hunk ниже указываются назначение, владелец и причина внутренней инъекции. Полный diff `code/` проверяется, чтобы не переносить переработку из `code/modules/` в controllers/datums. Компиляция, внешние headless DM-регрессии, Python/Bun, TGUI/browser и настоящий игровой клиент — отдельные уровни доказательства.

Внешний regression bundle запускается в изолированном TEMP checkout и закрепляет исходники/hashes. Четыре сочетания donor flags проверяются независимо. Восстановление native определений и отключение старого runtime-протокола проверяются раздельно. Старые результаты сборки не переносятся на новый HEAD.

Production launcher/save root не подтверждены; реальные saves не изменяются. До запуска нужна [offline migration/readiness](../../tools/migrate_job_slots/README.md). Headless проверки не доказывают подключение настоящего клиента, игровые modal или расстановку landmarks на DMM.

## Оставшиеся core-hunks

Позиции относятся к этому состоянию исходников; изменения аргумента учитываются как одна удалённая и одна добавленная строка. Полных удалений процедур и многострочных замен нет. Native middleware jobs полностью совпадает с базой.

| Core-hunk (текущая строка) | Владелец | Зачем нужна внутренняя точка |
| --- | --- | --- |
| `code/controllers/subsystem/dynamic/_dynamic_ruleset.dm:238` | dynamic | Снимки до/после inline prepare и blacklist. Wrapper prepare_for_role не видит последующее native добавление blacklist. |
| `code/controllers/subsystem/dynamic/_dynamic_ruleset.dm:241` | dynamic | Снимки до/после inline prepare и blacklist. Wrapper prepare_for_role не видит последующее native добавление blacklist. |
| `code/controllers/subsystem/dynamic/dynamic_ruleset_roundstart.dm:119` | dynamic | Адаптация species выбранного job profile до сохранённого trait check; wrapper после родителя не может отменить неверный native veto. |
| `code/controllers/subsystem/job.dm:250` | jobs / job_slots_preferences | Передача latejoin в штатный eligibility и окончательная подготовка до vacancy increment. Post-wrapper уже не предотвращает занятие вакансии. |
| `code/controllers/subsystem/job.dm:317` | jobs: random assignment | После сохранённого native eligibility if/continue отдельная инъекция проверяет только текущий explicit opt-in. Ни SQL, ни исходный допуск не заменяются. |
| `code/controllers/subsystem/job.dm:956` | jobs / job_slots_preferences | Контекст latejoin в сигнатуре нужен существующим внутренним age-check и вызовам selected-profile policy. |
| `code/controllers/subsystem/job.dm:980` | jobs / job_slots_preferences | После SQL lobby может быть удалён. Внутренний guard нужен до native чтения player.client. |
| `code/controllers/subsystem/job.dm:983` | jobs / job_slots_preferences | Проверка client после SQL и подстановка возраста выбранного профиля. Штатная age-ветка и код отказа сохраняются. |
| `code/controllers/subsystem/networks/id_access.dm:524` | jobs: ID templates prerequisite | Guard отсутствующего bank account в единственном native access алгоритме. Parent иначе обращается к null до возврата. |
| `code/controllers/subsystem/ticker.dm:468` | jobs / dynamic | Снимок selection/mind до создания и joined-list append. Внешний wrapper всего ticker не видит границу отдельного игрока. |
| `code/controllers/subsystem/ticker.dm:472` | jobs / dynamic | Освобождение снимка на штатном missing-destination continue; native ветка сохраняется. |
| `code/controllers/subsystem/ticker.dm:475` | jobs / dynamic | Проверка фактического тела и owned rollback сразу после constructor, до equip. Внешний post-wrapper слишком поздний. |
| `code/datums/outfit.dm:260` | jobs: outfit supplies | Handled hook перед сохранённой storage-операцией. Post-wrapper не возвращает удалённый del_on_fail предмет; весь цикл не копируется. |
| `code/datums/records/manifest.dm:21` | jobs: initial record | Roundstart помечает первоначальную job-запись; последующие identity updates не повторяют стартовые эффекты. |
| `code/datums/records/manifest.dm:106` | jobs: initial record | Явный initial_job_record контекст в общей сигнатуре; обычные вызовы сохраняют FALSE. |
| `code/datums/records/manifest.dm:141` | jobs: initial record | Ссылка на тот же единственный созданный record нужна callback; нового второго record нет. |
| `code/datums/records/manifest.dm:161` | jobs: initial record | Callback получает точный record сразу после создания. Lookup по имени во внешнем wrapper неоднозначен. |
| `code/modules/admin/admin_verbs.dm:608` | jobs: admin dummy state | Явное состояние нового admin lobby перед штатным назначением. Сигнатура и вызов assign_role остаются native; отсутствие client не даёт обхода обычному игроку. |
| `code/modules/client/preferences.dm:272` | preferences | Editing slot до modal и проверка контекста после ожидания, до write. Wrapper всей ui_act не может отменить уже записанный цвет. |
| `code/modules/client/preferences.dm:283` | preferences | Editing slot до modal и проверка контекста после ожидания, до write. Wrapper всей ui_act не может отменить уже записанный цвет. |
| `code/modules/client/preferences_savefile.dm:255` | job_slots_preferences | Load hook до вложенного check_keybindings/save; save hook после native set_entry до единственного flush. Post-wrapper не обеспечивает нужный I/O порядок. |
| `code/modules/client/preferences_savefile.dm:350` | job_slots_preferences | Load hook до вложенного check_keybindings/save; save hook после native set_entry до единственного flush. Post-wrapper не обеспечивает нужный I/O порядок. |
| `code/modules/jobs/job_types/_job.dm:234` | jobs: variants / AI prerequisite | Модуль выбирает outfit до единственного native equip_outfit_and_loadout. Post-wrapper не отменит уже выданные вещи. |
| `code/modules/jobs/job_types/_job.dm:521` | jobs: variants / AI prerequisite | Захват lobby/mind до AI constructor, который сам переносит mind и может ждать. Внешний wrapper не видит локальное тело. |
| `code/modules/jobs/job_types/_job.dm:533` | jobs: variants / AI prerequisite | Возврат только захваченного AI mind до native qdel отклонённого тела; после родителя восстановление было бы поздним. |
| `code/modules/jobs/job_types/_job.dm:611` | jobs: variants / AI prerequisite | Client guard после yielding name lookup до native preference reads; алгоритм AI preferences сохранён. |
| `code/modules/jobs/job_types/_job.dm:658` | jobs: variants / AI prerequisite | Nullable client после spawn signal; штатные signal и overlay не копируются в модуль. |
| `code/modules/jobs/job_types/prisoner.dm:38` | jobs: Prisoner | Источник crime_name — сохранённое преступление этого тела; native handler продолжает memory/photo effects. |
| `code/modules/jobs/job_types/prisoner.dm:48` | jobs: Prisoner | Точная initial manifest record заменяет только local lookup result. Внешний wrapper не видит local target_record. |
| `code/modules/jobs/job_types/prisoner.dm:77` | jobs: Prisoner | Источник equipment crime синхронизирован с телом и once-only effects до native tattoo/equip; родитель выполняется. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:9` | jobs: latejoin UI | Подстановка species назначенного профиля без load; штатные config/trait проверки выполняются дальше. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:32` | jobs: latejoin UI | Снимок requester/profile до fallback eligibility и input. Singleton меню не хранит состояние игрока. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:36` | jobs: latejoin UI | Модуль преобразует список canonical titles в labels; native цикл и input остаются на месте. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:46` | jobs: latejoin UI | Разрешение label обратно в job только для того же requester/profile после input; native Attempt вызов сохранён. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:74` | jobs: latejoin UI | Requester захватывается до первого eligibility wait внутри native ui_data. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:106` | jobs: latejoin UI | После eligibility останавливается чтение удалённого либо сменившего client lobby. Post-wrapper не защищает внутренний цикл. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:110` | jobs: latejoin UI | Уже вычисленный availability входит в DTO; модулю не нужен второй SQL или сравнение текста ошибки. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:149` | jobs: latejoin UI | Guard удалённого lobby до следующей static-строки после SQL. Внешний post-wrapper не может остановить внутренний native цикл; исходный hidden-job conditional и порядок сохранены. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:168` | jobs: latejoin UI | Сохранённый ui_act прекращает обработку при handled результате настоящего parent authorization. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:180` | jobs: latejoin UI | Снимок профиля и edit_slot до исходной select_job ветки; её round/load/queue/species проверки сохранены. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:189` | jobs: latejoin UI | Повторная проверка того же selection после potentially yielding random chooser, до native spawn. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:242` | jobs: latejoin UI | Снимок запроса до штатного random цикла; безопасный receiver при утрате lobby. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:249` | jobs: latejoin UI | Explicit opt-in фильтрует кандидата перед штатной availability проверкой; random алгоритм не заменяется. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:252` | jobs: latejoin UI | Контекст и opt-in проверяются после eligibility wait до добавления кандидата; исходный unavailable continue сохранён. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:259` | jobs: latejoin UI | Guard после всего цикла покрывает rejected final SQL result; удалённый receiver не вызывается. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:273` | jobs: latejoin UI | Opt-in проверяется перед reroll modal, поскольку предпочтения могли измениться между подтверждениями. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:277` | jobs: latejoin UI | Подмена только отображаемой метки random job; исходные modal/options и цикл сохранены. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:279` | jobs: latejoin UI | После modal принимается ответ только прежнего requester/profile; безопасный receiver после hard-delete. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:284` | jobs: latejoin UI | Подтверждение не обходит снятый explicit opt-in; исходный return canonical job сохранён. |
| `code/modules/mob/dead/new_player/new_player.dm:137` | jobs: admission / player | Модульные причины отказа добавляются перед сохранённым generic fallback; штатный switch остаётся. |
| `code/modules/mob/dead/new_player/new_player.dm:152` | jobs: admission / player | Закрытая подпиской роль не считается альтернативной вакансией Assistant; исходный capacity цикл сохраняется. |
| `code/modules/mob/dead/new_player/new_player.dm:157` | jobs: admission / player | Передача latejoin в существующий eligibility вызов выбирает правильный профиль без повторного алгоритма. |
| `code/modules/mob/dead/new_player/new_player.dm:171` | jobs: admission / player | Respawn history проверяет назначенный slot; native localhost branch и history restriction остаются. |
| `code/modules/mob/dead/new_player/new_player.dm:188` | jobs: admission / player | Проверка request после arrivals/eligibility waits до native queue removal и role assignment. |
| `code/modules/mob/dead/new_player/new_player.dm:206` | jobs: admission / player | Компенсация своей вакансии перед сохранённым missing-destination CRASH. |
| `code/modules/mob/dead/new_player/new_player.dm:208` | jobs: admission / player | Только forced_slot input берётся из committed selection; native создание остаётся на месте. |
| `code/modules/mob/dead/new_player/new_player.dm:210` | jobs: admission / player | Зафиксированный admission rejection возвращается штатному caller; неожиданный null по-прежнему вызывает native CRASH. |
| `code/modules/mob/dead/new_player/new_player.dm:213` | jobs: admission / player | Результат handover проверяется до экипировки; неуспешный transfer не должен продолжать native tail. |
| `code/modules/mob/dead/new_player/new_player.dm:239` | jobs: admission / player | Client может исчезнуть после handover callbacks; nullable вызов сохраняет native init_verbs. |
| `code/modules/mob/dead/new_player/new_player.dm:270` | jobs: admission / player | Latejoin помечает первоначальную manifest job-запись для once-only callback. |
| `code/modules/mob/dead/new_player/new_player.dm:298` | jobs: admission / player | Selection/mind/job захватываются до native constructor и его ожиданий. Post-wrapper не видит эти local values. |
| `code/modules/mob/dead/new_player/new_player.dm:305` | jobs: admission / player | Final body/context validation до native mind transfer и history write, включая специализированные constructors. |
