# Git-защита и перенос

`AGENTS.md`, `.AGENTS/` и `tools/agents/` — общие исходники. Машинный `.codex/`, рабочий `task_state/` и старый `.AGENTS/local/` исключены из Git. Установка добавляет runtime-исключения в `.git/info/exclude` и локальный hook; проверка не откатывает индекс сама.

```powershell
tools/agents/local-only.ps1 -Action install
tools/agents/local-only.ps1 -Action check
```

Git guard опционален. Он разрешает общие исходники, отвергает добавление или изменение staged локальных данных и допускает удаление ранее закоммиченных runtime-файлов. Если guard установлен, не обходи его через force-add или no-verify. Custom hook, `core.hooksPath`, конфиг и чужой cache сохраняются; для их совмещения нужна явная интеграция. Hook — локальная защита, не серверная политика.

В связанных worktrees каталог hooks и `info/exclude` общий для репозитория. Установка guard затрагивает все эти worktrees. Offline-команда `tools/agents/check.ps1` проверяет guard в одноразовых fixtures и не требует установки в рабочем checkout.

## Другой checkout

Обычный путь — получить эту ветку через Git и выполнить `tools/agents/setup-tools.ps1`. Для передачи исходников без Git доступен экспорт:

```powershell
tools/agents/export-toolkit.ps1 -Destination (Join-Path $env:TEMP 'BandaStation-agent-toolkit')
# В созданном каталоге:
py -3 -B payload/tools/agents/toolkit.py verify --bundle .
./Install.ps1 -Repository '<путь к BandaStation checkout>'
```

Экспорт создаёт новую папку и отказывается заменять существующую. Внутри: `payload/` с общими исходниками, `Install.ps1`, короткий README и SHA256 manifest. Истории задач, машинного конфига, зависимостей, ревью и Git metadata там нет. Незаявленные файлы, редиректы и несовпадающие хеши отвергаются.

Install проверяет BandaStation entrypoints и Git root до записи. Существующие совпадающие файлы допускают повторный запуск, различающиеся не перезаписываются. Новые общие файлы видны в Git как untracked; установщик не индексирует и не коммитит их. Runtime-исключения ставятся до генерации конфига. MCP-пути создаются заново для целевого checkout.

По умолчанию перенос запускает setup с `-ConfigOnly`; `-InstallDependencies` устанавливает закреплённые зависимости. После переноса выполни offline `check.ps1`. Если MCP нужен и его зависимости установлены, запусти соответствующий smoke из [TOOLS](TOOLS.md). Установка набора и его перенос не требуются для обычной работы с репозиторием.

Для другого проекта сначала адаптируй контекст, инструкции, include/build и skill по реальным исходникам. Установщик намеренно требует `tgstation.dme` и `modular_bandastation/modular_bandastation.dme`.
