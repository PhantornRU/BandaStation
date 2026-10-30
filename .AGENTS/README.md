# Агентский набор BandaStation

Вход — [AGENTS.md](../AGENTS.md). Общие исходники набора хранятся в Git; машинная конфигурация и текущие задачи — локально.

| Документ | Назначение |
| --- | --- |
| [PROJECT_CONTEXT](PROJECT_CONTEXT.md) | Карта исходников, include graph и сборка |
| [WORKFLOW_RULES](WORKFLOW_RULES.md) | Выбор места изменения, `..()` и точки расширения |
| [TASK_STATE](TASK_STATE.md) | Продолжение задач и работа нескольких исполнителей |
| [TOOLS](TOOLS.md) | Установка, использование и проверка двух MCP |
| [PORTING](PORTING.md) | Git-защита и перенос общих исходников |
| [KNOWN_ISSUES](KNOWN_ISSUES.md) | Границы инструментов |
| [bandastation-workflow](skills/bandastation-workflow/SKILL.md) | Краткий проектный skill |

Для работы с репозиторием достаточно правил AGENTS.md и доступных инструментов. MCP и локальные записи задач подключаются по потребности. Для установки MCP используй `tools/agents/setup-tools.ps1`, затем `tools/agents/check.ps1`; предпосылки и smoke-команды перечислены в TOOLS.

На Windows `.AGENTS` и `.agents` обозначают один каталог. Рабочие записи задач находятся отдельно в `task_state/`; в переносимый набор они не входят.
