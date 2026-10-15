// Static metadata may enrich the current server list, never restore hidden jobs.
export function mergeLatejoinDepartments<
  Department extends { jobs: Record<string, object> },
>(
  departments: Record<string, Department>,
  metadata: Record<string, Department>,
): Record<string, Department> {
  return Object.fromEntries(
    Object.entries(departments).map(([name, department]) => [
      name,
      {
        ...metadata[name],
        ...department,
        jobs: Object.fromEntries(
          Object.entries(department.jobs).map(([jobName, job]) => [
            jobName,
            {
              ...metadata[name]?.jobs[jobName],
              ...job,
            },
          ]),
        ),
      },
    ]),
  );
}
