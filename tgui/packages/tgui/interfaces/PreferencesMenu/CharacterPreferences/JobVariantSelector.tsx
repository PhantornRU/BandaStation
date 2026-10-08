import { useBackend } from 'tgui/backend';
import { Dropdown, Tooltip } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

export function JobVariantSelector(props: { jobName: string }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const job = data.donor_jobs?.[props.jobName];
  if (!job || job.variants.length < 2) {
    return null;
  }

  const selected = job.variants.find((variant) => variant.id === job.selected);
  return (
    <Tooltip content="Вариант активного персонажа. Для другого назначенного слота настройте вариант в его профиле.">
      <div>
        <Dropdown
          width="100%"
          selected={selected?.name}
          options={job.variants.map((variant) => ({
            value: variant.id,
            displayText: variant.name,
          }))}
          onSelected={(variant: string) =>
            act('set_donor_job_variant', {
              job: props.jobName,
              slot: data.active_slot,
              variant,
            })
          }
        />
      </div>
    </Tooltip>
  );
}
