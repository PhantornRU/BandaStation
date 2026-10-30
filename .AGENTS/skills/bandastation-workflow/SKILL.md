---
name: bandastation-workflow
# Describe the trigger without prescribing module placement
description: Use when implementing or reviewing BandaStation DM, TGUI, map or port changes.
---

# Работа с BandaStation

Основные правила находятся в [AGENTS.md](../../../AGENTS.md); [PROJECT_CONTEXT](../../PROJECT_CONTEXT.md) помогает найти исходники и сборку. Это памятка по проекту, а не отдельная политика разработки.

Выбирай место изменения по соседнему коду, владельцу состояния и цене upstream merge. Новая логика может находиться в существующем upstream-файле или `modular_bandastation/`; каталог сам по себе не определяет правильность решения. [Памятка по расширению](../../WORKFLOW_RULES.md) поясняет контракты `..()`, возвращаемых данных и точек расширения.

Проверь реальный include graph и потребителя изменения. Для переводов имён редактируются TOML fragments, а не generated `ru_names.toml`. Команды сборки и проверок сверяются с текущими исходниками и разделом Testing and verification в AGENTS.md.

[Локальные записи задач](../../TASK_STATE.md) и [MCP](../../TOOLS.md) опциональны. Используй их по потребности; обычная правка может выполняться без установки набора и без создания task state.
