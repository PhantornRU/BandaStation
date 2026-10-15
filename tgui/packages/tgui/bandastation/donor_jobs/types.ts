export type DonorJobsData = {
  donor_jobs?: Record<
    string,
    {
      title: string | null;
      profile_title: string | null;
      selected: string | null;
      icon: string;
      variants: { id: string; name: string }[];
      required_tier: number;
      lock_reason: string | null;
    }
  >;
};
