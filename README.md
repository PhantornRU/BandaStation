# Внешние регрессионные проверки BandaStation PR11

Source-only replay: 80 DM-регрессий, 21 Python-тестов и 1 Bun-тест. Внешний overlay подключается только в отдельном TEMP checkout.

- Product commit: `b9feef39fdc825cfe3992f3f5251d19f16a1e119`.
- Product tree: `de50353062327c9c7b695a87559bfdff41635e46`.
- BASE: `820de7f6ef9235d8417250cb01eec15da6735b18`.
- SHA256 `manifest.json`, `EXECUTED_MANIFEST.json` и `CANONICAL_MANIFEST.json`: `91f656392df5ffa6156a3d42f4a283b2cb0e2c1eaea403858127966e4ce5ef6a`.

Доказательство относится к одному свежему завершённому `--suite all` со статусом PASS: production build с новым TGUI bundle, native harness compile без внешнего overlay, native preservation, Python, Bun, external DM compile и все режимы 00/01/10/11. В каждом режиме — точный набор из 80 успешных тестов, clean_run и штатное завершение без runtime errors/BUG. Проверены DMB, ресурсы, обе DLL и фактические флаги каждого runtime. Подробности и hashes: [VERIFICATION.json](VERIFICATION.json).

Все 59 sealed файлов опубликованы побайтно как исполненные входы, без EOL/metadata адаптаций. Две manifest-копии идентичны исполнявшемуся manifest. `.gitattributes` сохраняет эти bytes независимо от core.autocrlf. Публикация содержит 65 явно перечисленных файлов. Исторические сбои других запусков не используются как доказательство этого PASS.

## Воспроизведение

Нужны Windows, Git, Python3.11+, BYOND516.1685, Bun1.3.5 и Cutterv5.0.1; версии сверяйте с dependencies.sh. Binary dependencies не поставляются; hashes проверяются по локальным settings. Для source invariants нужен rg. SOURCE_INPUTS фиксирует исходные checkout bytes; для auto-text paths используйте Windows core.autocrlf=true.

```powershell
git -c core.autocrlf=true clone https://github.com/PhantornRU/BandaStation.git ../BandaStation
git -C ../BandaStation checkout --detach b9feef39fdc825cfe3992f3f5251d19f16a1e119
git -C ../BandaStation rev-parse 'HEAD^{tree}'
py -3 -B ./run.py --verify-bundle
py -3 -B ./source_invariants.py --repo ../BandaStation
Copy-Item ./settings.example.json ./settings.json
```

Сверьте tree, заполните локальные пути зависимостей в settings.json, затем:

```powershell
py -3 -B ./run.py --settings ./settings.json --repository ../BandaStation --suite all --artifacts ../pr11-replay-results
```

Runner проверяет SOURCE_INPUTS и sealed hashes, сначала собирает production и native harness без overlay, затем запускает внешние регрессии. TEMP bootstrap меняет только имя лога Python, чтобы избежать конфликта Windows writers; TEMP mock adapters перечислены в provenance. Исходный checkout проверяется на неизменность. [README_RU.md](README_RU.md), [provenance.json](provenance.json), отдельный [browser harness](browser/README.md).

## Границы доказательства

Headless/mock fixtures не подтверждают подключённый BYOND client, реальную localhost notification, live SQL, интерактивные modal или визуальное отображение. Browser harness и полный native unit runtime в этом запуске не выполнялись. Production launcher, его cwd/save root и реальная deployment migration/readiness остаются UNVERIFIED; реальные player saves не читались и не менялись. DMM-размещения донатных профессий не добавлялись; действует штатный fallback spawn. Проверки миграции используют только TEMP saves. Settings, зависимости, binaries, runtime logs, screenshots и player saves не публикуются.

Лицензия: [GNU AGPL v3](LICENSE); notices/provenance сохранены.
