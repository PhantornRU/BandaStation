<!-- AI EDIT START - Remove legacy workflow title -->
# Изменения и проверка результата
<!-- AI EDIT END -->

## Сначала установи рабочий путь

Прочитай точный запрос, текущую реализацию, includes, overrides/signals, callsites и потребителя результата. Установи владельца состояния, возможные ожидания и побочные эффекты. Для существенной задачи запиши цель, узкие пути, MUST/KEEP/REJECT/CHECK и проверяемые допущения в [task state](TASK_STATE.md).

<!-- AI EDIT START - Remove module-specific scope wording -->
Сохраняй чужие dirty-изменения. Не переименовывай переменные, не форматируй и не рефактори соседние алгоритмы ради удобства правки. Перед генератором установи все входы и перезаписываемые выходы.
<!-- AI EDIT END -->

<!-- AI EDIT START - Replace modularization policy with change contracts -->
## Контракт изменения

Выбирай место правки по текущей реализации и задаче. Отдельный модуль, override или инъекция не являются обязательным способом изменения. Новый файл должен входить в действующий include graph.

При изменении override сохраняй необходимые родительские вызовы и смысл возвращаемого результата. Проверки, запрещающие действие, выполняй до его побочных эффектов. Учитывай владение общими списками и повторную проверку состояния после ожидания.

Комментарии `SS220 EDIT` / `BANDASTATION EDIT`, включая варианты `ADDITION`, `REMOVAL`, `START` / `END`, — legacy. В новых правках их не добавляй и на ревью не требуй.

Явный запрос пользователя определяет scope; обычные решения внутри него не требуют отдельного согласования.
<!-- AI EDIT END -->

## Где брать код-стайл

Источники: [STYLE](../.github/guides/STYLE.md), [STANDARDS](../.github/guides/STANDARDS.md), [AUTODOC](../.github/guides/AUTODOC.md), [CONTRIBUTING](../.github/CONTRIBUTING.md), [TGUI README](../tgui/README.md). Проверяй актуальные конфиги линтеров и стиль соседнего кода; старые нарушения не оправдывают новые.

Для DM: табы, полные typepaths, статические типы вместо доступа через `:`, понятные имена и константы. Учитывай контракт сигналов, `SIGNAL_HANDLER` и запрет ожидания в синхронном обработчике. Не дублируй алгоритмы. У цикла должен быть прогресс; отдельно проверь nested/associative list-семантику.

<!-- AI EDIT START - Remove mandatory modular TGUI integration -->
Для TGUI сначала проверь DM `ui_data/ui_act`, реальный компонент и существующие точки композиции. Используй штатные компоненты и стили. Не заменяй весь интерфейс, dispatcher или render ради одного дополнения.
<!-- AI EDIT END -->

## Как принять результат

| Изменение | Проверка |
| --- | --- |
| DM | Includes/callsites, штатная сборка, относящийся unit/runtime сценарий |
| TGUI | DM-контракт, lint/types/tests по области, реальная страница и кадр |
| Карты/ресурсы | Include/binding, maplint или DMI-проверка; runtime/кадр для поведения и внешнего вида |
| Переводы | Исходные TOML fragments, merge/schema и потребитель; generated файл вручную не править |
| Агентский набор | `tools/agents/check.ps1`, Git-границы, целевые сценарии |
| MCP/установщик | Чистая установка/повтор, initialize → tools/list → tools/call → shutdown |

Build targets сверяй с `tools/build/build.ts` и [build README](../tools/build/README.md). DreamMaker-only не проверяет весь pipeline. Браузерный MCP проверяет веб-страницу, а не полноценный BYOND runtime.

<!-- AI EDIT START - Verify contracts without requiring legacy extension paths -->
Смотри весь diff к базе задачи, а не только последний коммит: контракты затронутых путей сохранены, нет неисполняемых хвостов и лишних обёрток. Compile PASS этого не доказывает. Выполни `git diff --check`, обнови TODO/evidence и укажи ограничения. Не повторяй успешные проверки без нового изменения или неопределённости.
<!-- AI EDIT END -->
