# Внешние регрессионные проверки BandaStation PR11

82 DM-регрессии, 21 Python-тест и 1 Bun-тест. Product commit `b9f024dc4ebb06fe87b34adad5aa5ea348e3e736`, tree `351bb89236525d65beffe2df11a1798012dab429`, BASE `820de7f6ef9235d8417250cb01eec15da6735b18`.

`manifest.json` SHA256 `2b3f18ef43d690feb9d6a1b75043a5b154db291a52e208e69a895234f782c218` побайтно совпадает с исполненным финальным DM manifest. `CANONICAL_MANIFEST.json` относится к отдельным production/native фазам. Это составное доказательство на одном продуктовом дереве, а не один успешный `all`: первый прогон остановился на стандартном Bun timeout; тот же тест прошёл с 30000ms. Затем исправлены два выражения membership и устаревшее ожидание потери legacy-назначений во внешних fixtures. Продукт не менялся. Подробности: [VERIFICATION.json](VERIFICATION.json).

Production build с новой TGUI и native CIBUILDING без overlay прошли. Python 21/21, Bun 1/1. Финальный DM compile и 82/82 в каждом режиме 00/01/10/11 прошли с exit0, clean_run и без runtime error/BUG. Проверены совпадение names/status, hashes DLL и неизменность исходной копии.

Нужны Windows, Git, Python3.11+, BYOND516.1685, Bun1.3.5, Cutterv5.0.1 и локальные зависимости из settings.example.json. Настройки, бинарники и настоящие saves не публикуются.

```powershell
git -c core.autocrlf=true clone https://github.com/PhantornRU/BandaStation.git ../BandaStation
git -C ../BandaStation checkout --detach b9f024dc4ebb06fe87b34adad5aa5ea348e3e736
py -3 -B ./run.py --verify-bundle
Copy-Item ./settings.example.json ./settings.json
# Заполните локальные пути зависимостей.
py -3 -B ./run.py --settings ./settings.json --repository ../BandaStation --suite all
```

Все sealed файлы опубликованы как исполненные bytes. Для auto-text inputs используется core.autocrlf=true; explicit eol=lf сохраняется. [Происхождение](provenance.json), [запуск и ограничения](README_RU.md).

Headless не подтверждает подключённый BYOND client, live SQL, modal YES, localhost notification или sprites. Browser harness и полный native runtime suite не выполнялись. Production launcher/save root не подтверждены; реальные saves не читались и не менялись. Лицензия [AGPLv3](LICENSE).
