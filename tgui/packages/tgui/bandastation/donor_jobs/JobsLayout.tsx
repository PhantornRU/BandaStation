import type { ComponentProps } from 'react';
import { Section, Stack } from 'tgui-core/components';

import { JobList } from './JobList';
import { JobTabsProvider } from './JobTabs';

export function JobsLayout(props: ComponentProps<typeof Stack>) {
  return (
    <JobTabsProvider>
      <Stack {...props} />
    </JobTabsProvider>
  );
}

export function JobsSection(props: ComponentProps<typeof JobList>) {
  return (
    <Section fill scrollable>
      <JobList {...props} />
    </Section>
  );
}
