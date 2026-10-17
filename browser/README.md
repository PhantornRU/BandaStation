# Browser replay: реальные React components и canonical CSS

Это отдельный portable harness с synthetic backend. Он не подменяет BYOND runtime и не проверяет серверное применение actions. В браузер загружаются компоненты из явно переданного production-source checkout; SCSS imports при JS bundle пропускаются, а готовый CSS берётся только из `PRODUCTION_SOURCE/tgui/public/tgui.bundle.css`. Старые build/PASS не включены.

## Входы

- Новый frozen production-source checkout с установленными штатными `tgui` dependencies и завершённой штатной production-сборкой. Используйте pinned Bun из `dependencies.sh`, через `tools/bootstrap/javascript.bat` этого source.
- Тот же исходный checkout для сравнения source hashes; generated CSS не обязан быть там собран.
- Python 3 для source binding и браузер с developer tools или browser MCP для исполнения assertions.

Аргументы путей должны указывать на эти реальные каталоги. Не используйте исходники одной версии с CSS другой.

## Запуск (PowerShell)

Из каталога `browser` задайте `$productionSource` и `$checkoutRoot` абсолютными путями. В отдельном терминале:

```powershell
$browserBundle = (Get-Location).Path
& "$productionSource/tools/bootstrap/javascript.bat" "$browserBundle/serve.ts" "$productionSource"
```

Команда собирает только отдельный browser JS bundle из реальных React source. HTTP server слушает случайный свободный `127.0.0.1` port и печатает `UI_FIXTURE` с URL и своим PID. `dist/` — временный результат, не часть переносимого bundle.

После запуска зафиксируйте binding:

```powershell
py -3 -B ./bind_sources.py "$productionSource" "$checkoutRoot" before
```

Откройте выведенный URL. Выполните содержимое `browser-checks.js` как JavaScript async function expression, например browser MCP `browser_evaluate` получает точное содержимое файла в поле `function`. Для developer tools выполните `(CONTENTS_OF_BROWSER_CHECKS)()`; это только обозначение вставки содержимого, не literal команда. Объект результата также доступен как `window.__contractResults`. Сохраните полученный JSON отдельно от sealed bundle. Ожидается **27/27 assertions** на synthetic backend, `pass=true`; ошибки и предупреждения console проверьте отдельно. Снимите кадр Подписки, переключите вкладку Обычные и снимите второй кадр. Кадры и logs не входят в переносимый source bundle.

После проверки:

```powershell
py -3 -B ./bind_sources.py "$productionSource" "$checkoutRoot" final
Invoke-WebRequest "http://127.0.0.1:PORT/stop"
```

Замените PORT на порт своего server. Endpoint останавливает только этот harness. `source-binding-before.json` и `source-binding-final.json` сохраняют byte hashes components/CSS/harness; final проверяет неизменность. Эти evidence-файлы тоже храните вне публикуемого bundle. Свежесть canonical production build доказывает отдельный production log общего pipeline, а не один CSS hash.

## Проверяемые контракты

- Обычные/Подписка, три тира, единый DOM Section, loading/recovery, donor OFF, provider state после смены профиля.
- Настоящие canonical CSS tier grid и `.JobHudIcon` 16×16/pixelated; PNG synthetic 1×1 проверяет decode/стили, а не игровые sprites.
- Выбор варианта использует `job_variants` DTO и `set_job_variant` action; selected-profile tooltip читает `job_character_profiles.public_title`.
- Старый UI A после backend B отправляет captured A; свежий B — B. Отдельно проверяются priority, variant, assigned slot и latejoin selection, canonical job identity сохраняется.
- Dynamic latejoin rows остаются authoritative: static metadata дополняет description, не возвращает скрытые профессии/отделы и не перезаписывает availability/title/slots. Недоступная строка selection не отправляет.

Количество jobs сокращено намеренно. DM fixtures отдельно проверяют headless/mock контракты native authentication, SQL yield и владения телом. Реальный подключённый BYOND client и его possession этим набором не проверены.
