async () => {
  const result = { fixture: 'Frozen real React source and canonical production CSS, synthetic backend; not BYOND', tests: [] };
  window.__contractResults = result;
  const wait = () => new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
  const check = (name, pass, actual) => result.tests.push({ name, pass: !!pass, actual });
  const tab = (text) => [...document.querySelectorAll('.Tab')].find((node) => node.textContent.trim() === text);
  const rows = () => [...document.querySelectorAll('.PreferencesMenu__Department .job-name')].map((node) => node.textContent.trim());
  const barber = () => [...document.querySelectorAll('.PreferencesMenu__Department')].find((node) => node.querySelector('.job-name')?.textContent.includes('Парикмахер'));
  const priority = (text) => [...barber().querySelectorAll('.PreferencesMenu__PriorityButton')].find((node) => node.textContent.trim() === text);
  const listSection = () => document.querySelector('.PreferencesMenu__Jobs, .PreferencesMenu__JobTiers')?.closest('.Section');

  fixture.setPreferences({ activeSlot: 1 });
  await wait();
  tab('Обычные')?.click();
  await wait();
  const ordinary = rows();
  check('ordinary fallback uses native rows and three columns', ordinary.length === 2 && ordinary.includes('Ассистент') && ordinary.includes('Грузчик') && document.querySelector('.PreferencesMenu__Jobs').children.length === 3, ordinary);
  check('both tab controls provided', !!tab('Обычные') && !!tab('Подписка'), [...document.querySelectorAll('.Tab')].map((n) => n.textContent.trim()));
  const sharedSection = listSection();
  const scrollContent = sharedSection.querySelector('.Section__content');
  result.section = { className: sharedSection.className, contentClass: scrollContent?.className, overflowY: scrollContent && getComputedStyle(scrollContent).overflowY, dimensions: { width: sharedSection.getBoundingClientRect().width, height: sharedSection.getBoundingClientRect().height } };
  check('common Section fill and scroll container present', sharedSection.classList.contains('Section--fill') && sharedSection.classList.contains('Section--scrollable'), result.section);

  tab('Подписка').click();
  await wait();
  const tierNames = [...document.querySelectorAll('.PreferencesMenu__JobTier > .Section__title')].map((n) => n.textContent);
  check('subscription lists all three tiers with canonical shared rows', document.querySelectorAll('.PreferencesMenu__JobTier').length === 3 && rows().length === 3 && !!barber(), { tierNames, rows: rows() });
  check('tab switch preserves common Section DOM element', sharedSection === listSection(), listSection()?.className);
  const tierStyle = getComputedStyle(document.querySelector('.PreferencesMenu__JobTierJobs'));
  const icon = barber().querySelector('.JobHudIcon');
  await icon.decode();
  check('canonical CSS styles tier grid and HUD icon', tierStyle.display === 'grid' && getComputedStyle(icon).width === '16px' && getComputedStyle(icon).height === '16px' && getComputedStyle(icon).imageRendering === 'pixelated', { grid: tierStyle.display, icon: { width: getComputedStyle(icon).width, height: getComputedStyle(icon).height, rendering: getComputedStyle(icon).imageRendering, decoded: icon.naturalWidth > 0 } });

  fixture.setPreferences({ activeSlot: 2 });
  await wait();
  check('provider keeps subscription state during profile rerender', !!barber() && !!document.querySelector('.PreferencesMenu__JobTiers') && tab('Подписка').classList.contains('Tab--selected'), { activeSlot: fixture.currentData().active_slot, rows: rows() });
  check('profile rerender keeps common Section DOM element', sharedSection === listSection(), listSection()?.className);

  fixture.setPreferences({ serverPrefsReady: false });
  await wait();
  const loadingSection = document.querySelector('.PreferencesMenu__Jobs')?.closest('.Section');
  check('public serverPrefs loading path keeps Section and no rows/tabs', loadingSection === sharedSection && rows().length === 0 && !tab('Подписка') && !document.querySelector('.PreferencesMenu__JobTiers'), { className: loadingSection?.className, rows: rows(), tabs: document.querySelectorAll('.Tab').length });
  fixture.setPreferences({ activeSlot: 2 });
  await wait();
  check('provider selection survives serverPrefs loading/recovery', !!barber() && !!document.querySelector('.PreferencesMenu__JobTiers') && tab('Подписка').classList.contains('Tab--selected') && listSection() === sharedSection, rows());

  fixture.setPreferences({ donorEnabled: false });
  await wait();
  check('donor OFF renders ordinary native fallback without tabs/tiers', rows().length === 2 && rows().includes('Ассистент') && rows().includes('Грузчик') && !document.querySelector('.PreferencesMenu__JobTiers') && !tab('Подписка') && !tab('Обычные'), rows());
  check('donor OFF keeps same common Section', listSection() === sharedSection, listSection()?.className);

  fixture.setPreferences({ activeSlot: 1 });
  await wait();
  tab('Подписка')?.click();
  await wait();
  const retainedA = priority('Откл.');
  fixture.resetActions();
  fixture.switchBackendSlotWithoutRender(2);
  retainedA.click();
  await wait();
  const staleAction = window.__acts.find(([action]) => action === 'act/set_job_preference');
  check('retained row A after backend B sends captured A', staleAction?.[1]?.edit_slot === 1 && staleAction[1].job === 'Barber', staleAction);
  fixture.setPreferences({ activeSlot: 2 });
  await wait();
  fixture.resetActions();
  priority('Низк.').click();
  await wait();
  const freshAction = window.__acts.find(([action]) => action === 'act/set_job_preference');
  check('fresh row B sends captured B', freshAction?.[1]?.edit_slot === 2 && freshAction[1].job === 'Barber' && freshAction[1].level === 1, freshAction);

  fixture.setPreferences({ activeSlot: 1, randomized: true });
  await wait();
  tab('Подписка')?.click();
  await wait();

  const helpers = fixture.helpers();
  check('selected profile tooltip reads assigned-character public title', helpers.tooltip === 'В начале раунда: 2. Выбранный B, случайная внешность, Стилист B', helpers.tooltip);
  check('ordinary profile tooltip keeps the no-variant fallback', helpers.ordinaryTooltip === 'В начале раунда: 2. Выбранный B', helpers.ordinaryTooltip);
  check('profile error wins over display metadata', helpers.errorTooltip === 'Недоступный профиль', helpers.errorTooltip);
  check('missing profile keeps its unavailable fallback', helpers.missingTooltip === 'Профиль для входа недоступен', helpers.missingTooltip);
  check('latejoin static merge never restores hidden jobs and preserves dynamic admission', helpers.departments.join() === 'Cargo' && helpers.jobs.join() === 'Visible' && helpers.visible.description === 'static' && helpers.visible.public_title === 'dynamic' && helpers.visible.availability === 9 && helpers.visible.unavailable_reason === 'dynamic lock' && helpers.visible.open_slots === '∞' && helpers.empty.length === 0 && helpers.unchanged, helpers);

  async function openVariant(slot) {
    fixture.setPreferences({ activeSlot: slot });
    await wait();
    tab('Подписка')?.click();
    await wait();
    barber().querySelector('.job-name .Dropdown__control').click();
    await wait();
    return [...document.querySelectorAll('.Dropdown__menu--entry')].find(n => n.textContent === 'Стилист');
  }
  const retainedVariantA = await openVariant(1);
  fixture.resetActions();
  fixture.switchBackendSlotWithoutRender(2);
  retainedVariantA.click();
  await wait();
  const staleVariant = window.__acts.find(([action]) => action === 'act/set_job_variant');
  check('retained variant A after backend B sends canonical job, variant and captured slot A', staleVariant?.[1]?.slot === 1 && staleVariant[1].job === 'Barber' && staleVariant[1].variant === 'stylist', staleVariant);
  const freshVariantB = await openVariant(2);
  fixture.resetActions();
  freshVariantB.click();
  await wait();
  const freshVariant = window.__acts.find(([action]) => action === 'act/set_job_variant');
  check('fresh variant B sends captured slot B', freshVariant?.[1]?.slot === 2 && freshVariant[1].job === 'Barber', freshVariant);

  async function openSlot(slot) {
    fixture.setPreferences({ activeSlot: slot });
    await wait();
    tab('Подписка')?.click();
    await wait();
    barber().querySelector('.options .Dropdown__control').click();
    await wait();
    return [...document.querySelectorAll('.Dropdown__menu--entry')].find(n => n.textContent === '2. Выбранный B');
  }
  const retainedSlotA = await openSlot(1);
  fixture.resetActions();
  fixture.switchBackendSlotWithoutRender(2);
  retainedSlotA.click();
  await wait();
  const staleSlot = window.__acts.find(([action]) => action === 'act/set_job_slot');
  check('retained assignment A after backend B keeps editing slot A distinct from assigned slot B', staleSlot?.[1]?.edit_slot === 1 && staleSlot[1].slot === 2 && staleSlot[1].job === 'Barber', staleSlot);
  const freshSlotB = await openSlot(2);
  fixture.resetActions();
  freshSlotB.click();
  await wait();
  const freshSlot = window.__acts.find(([action]) => action === 'act/set_job_slot');
  check('fresh assignment B sends editing slot B', freshSlot?.[1]?.edit_slot === 2 && freshSlot[1].slot === 2, freshSlot);

  fixture.setLatejoin({editSlot:1, availability:9, unavailableReason:'Сохранённый профиль недоступен'});
  await wait();
  const lateButtons = () => [...document.querySelectorAll('.Button')];
  const lateJob = () => lateButtons().find(n => n.textContent.includes('Доставщик B'));
  fixture.resetActions();
  lateJob().click();
  await wait();
  check('unavailable latejoin row retains display but never sends selection', !window.__acts.some(([action]) => action === 'act/select_job') && lateJob().textContent.includes('1 / ∞'), {text:lateJob().textContent,actions:window.__acts});
  check('latejoin render uses only current dynamic jobs', !document.body.textContent.includes('HiddenStaticJob') && !document.body.textContent.includes('HiddenDepartment') && !document.body.textContent.includes('HiddenOtherJob') && [...document.querySelectorAll('.Section__titleText')].filter(n => n.textContent.includes('позиций доступно')).length === 1, document.body.textContent);
  fixture.setLatejoin({editSlot:1});
  await wait();
  const retainedJoinA = lateJob();
  fixture.resetActions();
  fixture.switchBackendSlotWithoutRender(2);
  retainedJoinA.click();
  await wait();
  const staleJoin = window.__acts.find(([action]) => action === 'act/select_job');
  check('retained latejoin A sends canonical job and captured slot A', staleJoin?.[1]?.edit_slot === 1 && staleJoin[1].job === 'Cargo Technician', staleJoin);
  fixture.setLatejoin({editSlot:2});
  await wait();
  fixture.resetActions();
  lateJob().click();
  await wait();
  const freshJoin = window.__acts.find(([action]) => action === 'act/select_job');
  check('fresh latejoin B sends captured slot B', freshJoin?.[1]?.edit_slot === 2 && freshJoin[1].job === 'Cargo Technician', freshJoin);
  fixture.setPreferences({activeSlot:1, randomized:true});
  await wait();
  tab('Подписка')?.click();
  await wait();

  result.counts = { total: result.tests.length, passed: result.tests.filter((t) => t.pass).length, failed: result.tests.filter((t) => !t.pass).length };
  result.pass = result.tests.every((t) => t.pass);
  return result;
}
