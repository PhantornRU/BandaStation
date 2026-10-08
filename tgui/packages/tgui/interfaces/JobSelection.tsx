import { Color } from 'tgui-core/color';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
  StyleableSection,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  DEPARTMENTS_RU,
  JOBS_RU,
  ReverseJobsRu,
} from '../bandastation/ru_jobs'; // BANDASTATION EDIT
import { Window } from '../layouts';
import { JOB2ICON } from './common/JobToIcon';

type Job = {
  unavailable_reason: string | null;
  command: BooleanLike;
  open_slots: number | string;
  used_slots: number;
  prioritized: BooleanLike;
  description: string;
  jobIcon: string;
  public_title: string; // BANDASTATION ADDITION: display identity differs from the canonical job key.
  character_profile: string; // BANDASTATION ADDITION
};

type Department = {
  color: string;
  jobs: Record<string, Job>;
  open_slots: number | string;
};

type Data = {
  departments_static: Record<string, Department>;
  departments: Record<string, Department>;
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: BooleanLike;
  priority: BooleanLike;
  round_duration: string;
  edit_slot: number; // BANDASTATION ADDITION
};

type JobEntryProps = {
  jobName: string;
  job: Job;
  department: Department;
  jobIcon: string;
  onClick: () => void;
};

function JobEntry(props: JobEntryProps) {
  const { jobName, job, department, onClick } = props;

  const jobIcon = JOB2ICON[ReverseJobsRu(jobName)] || null;

  return (
    <Button
      fluid
      style={{
        // Try not to think too hard about this one.
        backgroundColor: job.unavailable_reason
          ? '#949494' // Grey background
          : job.prioritized
            ? '#16fc0f' // Bright green background
            : Color.fromHex(department.color).darken(10).toString(),
        color: job.unavailable_reason
          ? '#616161' // Dark grey font
          : Color.fromHex(department.color).darken(90).toString(),
        fontSize: '1.1rem',
        cursor: job.unavailable_reason ? 'initial' : 'pointer',
      }}
      tooltip={
        <>
          {job.prioritized && !job.unavailable_reason && (
            <Box bold>The HoP wants more people in this job!</Box>
          )}
          <Box>{job.unavailable_reason || job.description}</Box>
          <Box mt={0.5} italic>
            {job.character_profile}
          </Box>
        </>
      }
      tooltipPosition="top"
      onClick={() => {
        !job.unavailable_reason && onClick();
      }}
    >
      <Stack fill>
        {jobIcon && (
          <Stack.Item>
            <Icon style={{ marginRight: '0.1em' }} name={jobIcon} />
          </Stack.Item>
        )}
        <Stack.Item grow>
          {job.command ? (
            <b>{job.public_title || JOBS_RU[jobName] || jobName}</b>
          ) : (
            job.public_title || JOBS_RU[jobName] || jobName
          )}
        </Stack.Item>
        <Stack.Item>
          <span
            style={{
              whiteSpace: 'nowrap',
            }}
          >
            {job.used_slots} / {job.open_slots}
          </span>
        </Stack.Item>
      </Stack>
    </Button>
  );
}

type DepartmentEntryProps = {
  name: string;
  department: Department;
};

function DepartmentEntry(props: DepartmentEntryProps) {
  const { name, department } = props;
  const { act, data } = useBackend<Data>();

  return (
    <Box minWidth="30%">
      <StyleableSection
        title={
          <>
            {name}
            <span
              style={{
                fontSize: '1rem',
                whiteSpace: 'nowrap',
                position: 'absolute',
                right: '1em',
                color: Color.fromHex(department.color).darken(60).toString(),
              }}
            >
              {`позиций доступно: ${department.open_slots}`}
            </span>
          </>
        }
        style={{
          backgroundColor: department.color,
          marginBottom: '1em',
          breakInside: 'avoid-column',
        }}
        titleStyle={{
          'border-bottom-color': Color.fromHex(department.color)
            .darken(50)
            .toString(),
        }}
        textStyle={{
          color: Color.fromHex(department.color).darken(80).toString(),
        }}
      >
        <Stack vertical>
          {Object.entries(department.jobs).map(([name, job]) => (
            <Stack.Item key={name}>
              <JobEntry
                key={name}
                jobName={name}
                job={job}
                jobIcon={job.jobIcon}
                department={department}
                onClick={() => {
                  act('select_job', { job: name, edit_slot: data.edit_slot });
                }}
              />
            </Stack.Item>
          ))}
        </Stack>
      </StyleableSection>
    </Box>
  );
}

export function JobSelection(props) {
  const { act, data } = useBackend<Data>();
  if (!data?.departments_static) {
    return null; // Stop TGUI whitescreens with TGUI-dev!
  }

  // BANDASTATION EDIT: static metadata must not resurrect jobs hidden by current availability.
  const departments: Record<string, Department> = Object.fromEntries(
    Object.entries(data.departments).map(([name, department]) => [
      name,
      {
        ...data.departments_static[name],
        ...department,
        jobs: Object.fromEntries(
          Object.entries(department.jobs).map(([jobName, job]) => [
            jobName,
            {
              ...data.departments_static[name]?.jobs[jobName],
              ...job,
            },
          ]),
        ),
      },
    ]),
  );

  const { shuttle_status, round_duration } = data;

  return (
    <Window width={1012} height={shuttle_status ? 690 : 666 /* Hahahahahaha */}>
      <Window.Content>
        <Section
          buttons={
            <Button
              onClick={() =>
                act('select_job', { job: 'Random', edit_slot: data.edit_slot })
              }
              tooltip="Случайно выбрать профессию. Вы можете повторно выбирать случайную профессию или отказаться от этого."
            >
              Случайная профессия!
            </Button>
          }
          fill
          scrollable
          title={
            <>
              {shuttle_status && <NoticeBox info>{shuttle_status}</NoticeBox>}
              <Box as="span" color="label">
                It is currently {round_duration} into the shift.
              </Box>
            </>
          }
        >
          <Box style={{ columns: '20em' }}>
            {Object.entries(departments).map(([name, department]) => (
              <DepartmentEntry
                key={name}
                name={DEPARTMENTS_RU[name] || name}
                department={department}
              />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
}
