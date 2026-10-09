import { useBackend } from 'tgui/backend';
import { Dropdown, Tooltip } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

const SLOT_ICONS = {
  0: 'user',
  1: 'fa-1',
  2: 'fa-2',
  3: 'fa-3',
  4: 'fa-4',
  5: 'fa-5',
  6: 'fa-6',
  7: 'fa-7',
  8: 'fa-8',
  9: 'fa-9',
};

type JobSlotDropdownProps = {
  name: string;
};

export const JobSlotDropdown = (props: JobSlotDropdownProps) => {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { name } = props;

  const currentProfileName = data.character_profiles[data.active_slot - 1];
  const currentSlotNumber = data.pref_job_slots[name] ?? 0;
  const currentSlotName =
    currentSlotNumber > 0
      ? data.character_profiles[currentSlotNumber - 1]
      : currentProfileName;

  const slotOptions = [
    {
      value: 0,
      displayText: currentProfileName
        ? `Активный персонаж (${currentProfileName})`
        : 'Активный персонаж',
    },
    ...data.character_profiles.flatMap((profile, index) =>
      profile
        ? [
            {
              value: index + 1,
              displayText: `${index + 1}. ${profile}`,
            },
          ]
        : [],
    ),
    {
      value: -1,
      displayText: 'Случайное имя и внешность активного персонажа',
    },
  ];
  const selectedOption = slotOptions.find(
    (option) => option.value === currentSlotNumber,
  );
  const entryProfile = data.job_character_profiles?.[name];
  const entryName = entryProfile?.slot
    ? data.character_profiles[entryProfile.slot - 1]
    : null;
  const profileTitle = data.donor_jobs?.[name]?.profile_title;
  const entryDescription = entryProfile?.error
    ? entryProfile.error
    : entryName
      ? `В начале раунда: ${entryProfile?.slot}. ${entryName}${entryProfile?.randomized ? ', случайная внешность' : ''}${profileTitle ? `, ${profileTitle}` : ''}`
      : 'Профиль для входа недоступен';

  return (
    <Tooltip
      content={`${selectedOption?.displayText ?? currentSlotName ?? 'Активный персонаж'}. ${entryDescription}`}
      position="top-end"
    >
      <div>
        <Dropdown
          noChevron
          iconOnly
          icon={
            currentSlotNumber === -1
              ? 'dice'
              : (SLOT_ICONS[currentSlotNumber] ?? 'user')
          }
          width="auto"
          menuWidth="auto"
          selected={selectedOption?.displayText}
          options={slotOptions}
          onSelected={(value: number | string) => {
            const slot = Number(value);
            act('set_job_slot', {
              job: name,
              slot,
              edit_slot: data.active_slot,
            });
          }}
        />
      </div>
    </Tooltip>
  );
};
