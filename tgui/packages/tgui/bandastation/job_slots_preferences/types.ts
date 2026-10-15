import type { BooleanLike } from 'tgui-core/react';

export type JobSlotsPreferencesData = {
  job_character_profiles?: Record<
    string,
    { slot: number | null; randomized: BooleanLike; error: string | null }
  >;
  pref_job_slots: Record<string, number>;
};

export type JobCharacterDisplayData = {
  public_title: string;
  character_profile: string;
  job_icon?: string;
};

export type LatejoinCharacterData = {
  edit_slot: number;
};
