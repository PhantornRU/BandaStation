import { useBackend } from 'tgui/backend';
import { Stack, Tooltip } from 'tgui-core/components';

import type { JobSlotsPreferencesData } from '../job_slots_preferences/types';
import type { DonorJobsData } from './types';

export function useJobRestriction(jobName: string) {
  const { data } = useBackend<DonorJobsData & JobSlotsPreferencesData>();
  const donorJob = data.donor_jobs?.[jobName];
  const reason =
    donorJob?.lock_reason || data.job_character_profiles?.[jobName]?.error;

  return {
    restricted: !!reason,
    notice: reason ? (
      <Tooltip content={reason}>
        <Stack.Item className="restricted">
          {donorJob?.lock_reason
            ? `Тир ${donorJob.required_tier}`
            : 'Профиль недоступен'}
        </Stack.Item>
      </Tooltip>
    ) : null,
  };
}
