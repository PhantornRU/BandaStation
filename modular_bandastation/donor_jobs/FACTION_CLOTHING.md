# Одежда ТСФ и СССП

Источник — [Paradise-SS220 71c8bb1b](https://github.com/ss220club/Paradise-SS220/tree/71c8bb1b88e29c352875865b362a1f8a99a205cc). Портированы отсутствующие изображения одежды этой ревизии, с нативными TG/BS типами и поведением. Современные военные комплекты BandaStation сохранены. Здесь нет нового набора профессий, оружия или переноса Paradise hardsuit-кода и баланса.

ТСФ: 19 исходных типов покрыты 17 конкретными косметическими подклассами. Два одинаковых варианта кепки и один повторный beret используют общие предметы; inventory-спрайты marine/specops уже существуют в BS и переиспользованы напрямую. У СССП добавлены 12 типов; старый советский костюм и ушанка используют существующие TG предметы.

Четыре существующие должности получают свои исходные uniform/head slots; tourist/representative СССП также получают обычную/офицерскую шинель. Остальные формы и космические пары доступны мапперам и администраторам как предметы. Они не добавлены автоматически к туристам и представителям. Обувь, перчатки, связь, доступы и импланты используют прежние TG/BS предметы.

## ТСФ

| Source item | Native appearance | Reason |
| --- | --- | --- |
| `/obj/item/clothing/under/solgov` | `/obj/item/clothing/under/rank/tsf/donor/marine` | Existing native inventory pixels reused; original worn pixels absent. |
| `/obj/item/clothing/under/solgov/elite` | `/obj/item/clothing/under/rank/tsf/donor/specops` | Existing native inventory pixels reused; original worn pixels absent. |
| `/obj/item/clothing/under/solgov/command` | `/obj/item/clothing/under/rank/tsf/donor/command` | Missing unique inventory/worn appearance. |
| `/obj/item/clothing/under/solgov/command/elite` | `/obj/item/clothing/under/rank/tsf/donor/command/specops` | Missing unique inventory/worn appearance. |
| `/obj/item/clothing/under/solgov/rep` | `/obj/item/clothing/under/rank/tsf/donor/representative` | Missing unique inventory/worn appearance. |
| `/obj/item/clothing/under/rank/centcom/captain/solgov` | `/obj/item/clothing/under/rank/tsf/donor/commander` | Missing inventory/worn/carry appearance; native TSF uniform behaviour. |
| `/obj/item/clothing/head/soft/solgov` | `/obj/item/clothing/head/soft/donor_tsf` | One native cap supports both orientations; no second item. |
| `/obj/item/clothing/head/soft/solgov/marines` | `/obj/item/clothing/head/soft/donor_tsf` | Source differs from preceding cap in armour/start orientation; no foreign armour imported. |
| `/obj/item/clothing/head/soft/solgov/marines/elite` | `/obj/item/clothing/head/soft/donor_tsf/specops` | Missing unique inventory/worn appearance. |
| `/obj/item/clothing/head/soft/solgov/marines/command` | `/obj/item/clothing/head/soft/donor_tsf/command` | Missing unique inventory/worn appearance. |
| `/obj/item/clothing/head/soft/solgov/marines/command/elite` | `/obj/item/clothing/head/soft/donor_tsf/command/specops` | Missing unique inventory/worn appearance; original worn spelling normalized. |
| `/obj/item/clothing/head/beret/solgov/command` | `/obj/item/clothing/head/beret/donor_tsf` | Native beret with original fixed-colour appearance. |
| `/obj/item/clothing/head/beret/solgov/command/elite` | `/obj/item/clothing/head/beret/donor_tsf/specops` | Native beret with original fixed-colour appearance. |
| `/obj/item/clothing/head/helmet/space/deathsquad/beret/solgov` | `/obj/item/clothing/head/beret/donor_tsf/specops` | Identical elite beret artwork; no duplicate item or pressure/200+ armour mechanics. |
| `/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov` | `/obj/item/clothing/head/helmet/space/donor_tsf` | Native TG space helmet; no camera/light/hardsuit code imported. |
| `/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov/command` | `/obj/item/clothing/head/helmet/space/donor_tsf/command` | Native TG space helmet; no camera/light/hardsuit code imported. |
| `/obj/item/clothing/suit/space/hardsuit/ert/solgov` | `/obj/item/clothing/suit/space/donor_tsf` | Native TG spacesuit; no source mechanics or armour balance imported. |
| `/obj/item/clothing/suit/space/hardsuit/ert/solgov/command` | `/obj/item/clothing/suit/space/donor_tsf/command` | Native TG spacesuit; no source mechanics or armour balance imported. |
| `/obj/item/clothing/suit/space/deathsquad/officer/solgov` | `/obj/item/clothing/suit/armor/donor_tsf_commander` | Native TG armour with existing armor_centcom_formal rating; no unsupported toggle or foreign armour. |

## СССП

| Источник | Нативное состояние до правки | Реализация / использование |
| --- | --- | --- |
| `/under/costume/soviet` | TG `/under/costume/soviet` уже существует | Используется существующий тип; второй предмет не добавлен. |
| `/head/ushanka` | TG `/head/costume/ushanka` уже существует | Используется существующий тип; второй предмет не добавлен. |
| `/under/new_soviet` | Современный BS `/under/rank/ussp/soldier` имеет другой art | Новый косметический `/under/costume/soviet/ussp`; tourist USSP. |
| `/under/new_soviet/sovietofficer` | BS `/under/rank/ussp/officer` имеет другой art | Новый `/under/costume/soviet/ussp/officer`; representative USSP. |
| `/under/new_soviet/sovietadmiral` | BS commander/official имеют другие sprites | Новый `/under/costume/soviet/ussp/admiral`; mapper/admin. |
| `/head/sovietsidecap` | BS `/head/hats/ussp` имеет другой art | Новый косметический `/head/hats/ussp/classic`; tourist USSP. |
| `/head/sovietofficerhat` | BS `/head/hats/ussp_officer` имеет другой art | Новый `/head/hats/ussp/classic/officer`; representative USSP. |
| `/head/sovietadmiralhat` | BS `/head/hats/ussp_command` имеет другой art | Новый `/head/hats/ussp/classic/admiral`; mapper/admin. |
| `/suit/sovietcoat` | BS `/suit/armor/vest/ussp` и TG soviet costume используют другой art | Новый косметический `/suit/costume/soviet/ussp`; tourist USSP. |
| `/suit/sovietcoat/officer` | BS `/suit/armor/vest/ussp/officer` имеет другой art | Новый `/suit/costume/soviet/ussp/officer`; representative USSP. |
| `/head/helmet/space/hardsuit/soviet` | Точной классической модели нет; есть Voskhod helmet и USSP MODs | Новый косметический `/head/helmet/space/ussp`, native space behavior. |
| `/suit/space/hardsuit/soviet` | Точной классической модели нет; есть Voskhod suit и USSP MODs | Новый `/suit/space/ussp`, native power cell, seal, thermal regulator. |
| `/head/helmet/space/hardsuit/soviet/commander` | Точной классической модели нет | Новый `/head/helmet/space/ussp/commander`, native space behavior. |
| `/suit/space/hardsuit/soviet/commander` | Точной классической модели нет | Новый `/suit/space/ussp/commander`, native space behavior. |

Префикс сокращённых путей СССП — `/obj/item/clothing`. Нативные космические родители предоставляют давление, броню, терморегулятор и питание; новые определения не переопределяют их процедуры. Командирское пальто ТСФ использует существующий `armor_centcom_formal`. Source фонари, камеры, охлаждение и foreign armour datums не перенесены; неиспользуемые light-on состояния исключены. Кепки используют штатные flip/drop; опечатка исходного worn-state `solgovcselitesoft` исправлена на `solgovcelitesoft`.

Пиксели и DMI frame/direction/animation metadata оставлены исходными. Для folded uniforms, шапок и обычных coats переиспользуются native inhand sprites; импортированы только отсутствующие commander-uniform и советские spacesuit inhand states. Список файлов, источник и лицензия — в [ATTRIBUTION](icons/ATTRIBUTION.md).

Два берета ТСФ используют существующий native `greyscale_softcap` в руках: это общий силуэт сложенного мягкого головного убора, а не отдельный порт берета. В закреплённом source нет beret inhand-state. Inventory и worn сохраняют оригинальные TSF sprites; `donor_tsf_beret_inhands` проверяет фактические штатные hand overlays обоих беретов в обеих руках и четырёх направлениях.

`donor_faction_outfits` независимо задаёт обязательные слоты четырёх ролей, проверяет реальную экипировку, ID и preview. `donor_tsf_caps` проверяет обе ориентации четырёх кепок и сброс после drop; `donor_tsf_spacesuits` — штатные pressure/armour/carry bindings. `ussp_clothing_assets` проверяет все 12 предметов, видимость во всех направлениях и реальные слоты; `ussp_space_clothing` — герметичность обеих пар, расход питания и выключение без заряда. Общая outfit enumeration отдельно проверяет выдачу объявленных вещей.

Штатный human/update_worn_undersuit использует icon_state как override_state. Поэтому девять source worn-state имён *_s приведены к canonical inventory state, включая tsf_marine/tsf_marsoc; пиксели, направления и анимация сохранены. donor_faction_uniform_overlays проверяет конечный слой униформы на мужском и женском теле во всех направлениях, а не только наличие заявленного worn_icon_state.
