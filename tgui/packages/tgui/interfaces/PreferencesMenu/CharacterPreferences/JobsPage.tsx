import { sortBy } from 'es-toolkit';
import type { CSSProperties, ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Color } from 'tgui-core/color';
import { Box, Button, Section, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
// BANDASTATION ADDITION START: donor job UI extension points
import { JobLabel } from '../../../bandastation/donor_jobs/JobLabel';
import {
  JobTabButtons,
  JobTabsProvider,
  useJobTabFilter,
} from '../../../bandastation/donor_jobs/JobTabs';
import { JOBS_RU } from '../../../bandastation/ru_jobs'; // BANDASTATION EDIT
// BANDASTATION ADDITION END
import {
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { JobSlotDropdown } from './JobSlotDropdown';

function sortJobs(entries: [string, Job][], head?: string) {
  return sortBy(entries, [
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  ]);
}

type PriorityButtonProps = {
  name: string;
  position: number;
  modifier?: string;
  selected: boolean;
  disabled?: boolean;
  onClick: () => void;
};

function PriorityButton(props: PriorityButtonProps) {
  const className = `PreferencesMenu__PriorityButton`;
  const positionVariable = {
    '--button-position': props.position,
  } as CSSProperties;

  return (
    <Button
      className={classes([
        className,
        props.modifier,
        props.selected && 'selected',
      ])}
      style={positionVariable}
      disabled={props.disabled}
      onClick={props.onClick}
    >
      {props.name}
    </Button>
  );
}

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

function createCreateSetPriorityFromName(jobName: string): CreateSetPriority {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  function createSetPriority(priority: JobPriority | null) {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    function setPriority() {
      const { act, data } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
        edit_slot: data.active_slot, // BANDASTATION ADDITION: reject a stale character row on the server.
      });
    }

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  }

  createSetPriorityCache[jobName] = createSetPriority;
  return createSetPriority;
}

type PriorityButtonsProps = {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority | null;
  restricted: boolean;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { createSetPriority, isOverflow, priority, restricted } = props;

  return (
    <Stack className="PreferencesMenu__Priority">
      {isOverflow ? (
        <>
          <PriorityButton
            name="Откл."
            modifier="off"
            position={1}
            selected={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Вкл."
            modifier="high"
            position={0}
            selected={!!priority}
            disabled={restricted}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name="Откл."
            modifier="off"
            position={3}
            selected={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Низк."
            modifier="low"
            position={2}
            selected={priority === JobPriority.Low}
            disabled={restricted}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Сред."
            modifier="mid"
            position={1}
            selected={priority === JobPriority.Medium}
            disabled={restricted}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="Выс."
            modifier="high"
            position={0}
            selected={priority === JobPriority.High}
            disabled={restricted}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Stack>
  );
}

type JobRowProps = {
  className?: string;
  name: string;
  job: Job;
};

function JobRow(props: JobRowProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const { className, job, name } = props;

  const jobPreference = data.job_preferences.find((pref) => pref.job === name);
  const priority = jobPreference?.priority ?? null;
  const isOverflow = data.overflow_role === name;
  const createSetPriority = createCreateSetPriorityFromName(name);

  let rightSide: ReactNode;
  const experienceNeeded = data.job_required_experience?.[name];
  const daysLeft = data.job_days_left?.[name] ?? 0;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack.Item className="restricted">
        <b>{hoursNeeded}ч.</b> как{' '}
        <Tooltip content={experience_type}>
          <span>{experience_type}</span>
        </Tooltip>
      </Stack.Item>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack.Item className="restricted">
        Нужно еще дней: <b>{daysLeft}</b>
      </Stack.Item>
    );
  } else if (data.job_bans?.includes(name)) {
    rightSide = <Stack.Item className="restricted ban">Забанен</Stack.Item>;
  }

  const donorJob = data.donor_jobs?.[name];
  const additionalReason =
    donorJob?.lock_reason || data.job_character_profiles?.[name]?.error;

  return (
    <Stack.Item className={className}>
      <Stack fill align="center">
        <Stack.Item grow minWidth={0} className="job-name">
          <JobLabel jobName={name} description={job.description} />
          {/* BANDASTATION EDIT */}
        </Stack.Item>
        <Stack.Item className="options">
          {rightSide}
          {!!additionalReason && (
            <Tooltip content={additionalReason}>
              <Stack.Item className="restricted">
                {donorJob?.lock_reason
                  ? `Тир ${donorJob.required_tier}`
                  : 'Профиль недоступен'}
              </Stack.Item>
            </Tooltip>
          )}
          <PriorityButtons
            createSetPriority={createSetPriority}
            isOverflow={isOverflow}
            priority={priority}
            restricted={!!rightSide || !!additionalReason}
          />
          <JobSlotDropdown name={name} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
}

type DepartmentProps = {
  department: string;
};

function Department(props: DepartmentProps) {
  const { department: name } = props;
  const className = `PreferencesMenu__Department`;

  const matchesJobTab = useJobTabFilter(); // BANDASTATION ADDITION
  const data = useServerPrefs();
  if (!data) {
    return;
  }

  const { departments, jobs, jobs_sorted } = data.jobs;
  const department = departments[name];

  if (!department) {
    return null;
  }

  const jobsForDepartment = jobs_sorted
    .map((jobName) => [jobName, jobs[jobName]] as const)
    .filter(
      ([jobName, job]) => job.department === name && matchesJobTab(jobName), // BANDASTATION EDIT
    );

  if (!jobsForDepartment.length) {
    return null;
  }

  return (
    <Box
      style={
        {
          '--department-color': Color.fromHex(department.color)
            .darken(10)
            .toString(),
        } as CSSProperties
      }
    >
      <Stack fill vertical g={0}>
        {jobsForDepartment.map(([jobName, job]) => {
          return (
            <JobRow
              key={jobName}
              name={jobName}
              job={job}
              className={classes([
                className,
                `${className}--${name.replace(' ', '')}`,
                jobName === department.head && 'head',
              ])}
            />
          );
        })}
      </Stack>
    </Box>
  );
}

function JoblessRoleDropdown() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;
  const options = [
    {
      displayText: `Присоединиться за ${JOBS_RU[data.overflow_role] || data.overflow_role}`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Выбрать случайную должность`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Вернуться в лобби`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const setPreference = createSetPreference(act, 'joblessrole');
  return (
    <Section
      title="Что делать если не удалось войти?"
      buttons={<JobTabButtons />} // BANDASTATION ADDITION: existing title extension point
    >
      <Stack fill textAlign="center">
        {options.map((option) => (
          <Stack.Item grow key={option.value}>
            <Button
              fluid
              color="transparent"
              selected={selected === option.value}
              onClick={() => setPreference(option.value)}
            >
              {option.displayText}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

export function JobsPage() {
  return (
    <JobTabsProvider>
      {/* BANDASTATION ADDITION */}
      <Stack fill vertical g={0}>
        <Stack.Item>
          <JoblessRoleDropdown />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Section fill scrollable>
            <Stack fill g={1} align="center" className="PreferencesMenu__Jobs">
              <Stack.Item grow minWidth={0}>
                <Stack vertical>
                  <Department department="Engineering" />
                  <Department department="Science" />
                  <Department department="Silicon" />
                  <Department department="Assistant" />
                </Stack>
              </Stack.Item>
              <Stack.Item grow minWidth={0}>
                <Stack vertical>
                  <Department department="Captain" />
                  <Department department="NT Representation" />
                  <Department department="Service" />
                  <Department department="Cargo" />
                </Stack>
              </Stack.Item>
              <Stack.Item grow minWidth={0}>
                <Stack vertical>
                  <Department department="Security" />
                  <Department department="Justice" />
                  <Department department="Medical" />
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </JobTabsProvider>
  );
}
