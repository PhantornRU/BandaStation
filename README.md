# Внешние регрессионные проверки BandaStation PR11

Этот отдельный source artifact содержит frozen replay bundle PR11: 77 DM fixtures, 21 Python test, 1 Bun test и browser harness. Feature PR содержит игровой код; тестовый overlay подключается только в новом TEMP checkout.

## Закреплённые входы

- Product commit: `705c370f528aa001e5857389b6cc766a231e8b5c`.
- Product tree: `8e6f8aae64a77ef40e226774b56c292cc1d9d233`.
- SHA256 `manifest.json`: `5bb0391e779890b32357137dbbdb178fa2b458db21488a38738ee43d6a611acc`.
- 56 sealed bundle files сохранены побайтно. Этот README и LICENSE являются дополнительными publication files и не меняют seal.

## Воспроизведение

Нужны Windows, Git, Python 3.11+, BYOND 516.1685, Bun 1.3.5 и Cutter v5.0.1 из требований проверяемого source. Runtime DLL и Cutter проверяются по SHA256 из settings; бинарные зависимости не поставляются. Для source invariants дополнительно нужен rg.

```powershell
git clone https://github.com/PhantornRU/BandaStation.git ../BandaStation
git -C ../BandaStation checkout --detach 705c370f528aa001e5857389b6cc766a231e8b5c
git -C ../BandaStation rev-parse 'HEAD^{tree}'
py -3 -B ./run.py --verify-bundle
py -3 -B ./source_invariants.py --repo ../BandaStation
Copy-Item ./settings.example.json ./settings.json
```

Сверьте выведенный tree с закреплённым выше. Заполните локальный settings.json путями зависимостей; все относительные пути разрешаются от его каталога. Затем:

```powershell
py -3 -B ./run.py --settings ./settings.json --repository ../BandaStation --suite all --artifacts ../pr11-replay-results
```

Runner сначала проверяет product SOURCE_INPUTS, затем выполняет production build, native compile и внешний overlay. DM runtime запускается в четырёх отдельных flag modes: 00, 01, 10, 11. Для каждого ожидаются ровно manifest test names и clean_run. Результаты/логи остаются в указанном внешнем artifacts directory. Изменения product source для тестов делаются только в новом detached TEMP worktree; исходная копия проверяется на неизменность.

Browser replay запускается отдельно по [browser/README.md](browser/README.md) с настоящими React components и свежим canonical production CSS. Полные инструкции и происхождение адаптаций: [README_RU.md](README_RU.md), [provenance.json](provenance.json).

## Границы доказательства

Наличие bundle и успешная проверка seal означают целостность source artifact. Они сами по себе не означают compile/runtime/browser PASS; результат связывается с конкретным product SHA/tree и логами запуска. `execution_status_at_seal` в manifest описывает состояние на момент seal и не переписывается результатами последующего запуска.

DM fixtures используют headless/mock client contracts там, где нет настоящего BYOND client; browser backend synthetic. Это не проверка настоящего подключённого клиента. Migration/readiness tests используют только TEMP saves: реальные production launcher, cwd, save root, конверсия и readiness этим artifact не подтверждаются. Реальные данные сервера не сканируются.

В публикацию не входят настройки локальных машин, зависимости, compiled/runtime artifacts, logs, screenshots или реальные player saves. Не добавляйте settings.json и результаты запусков в test source revision.

Лицензия: [GNU AGPL v3](LICENSE), скопирована из product repository. Существующие notices и provenance сохранены.
