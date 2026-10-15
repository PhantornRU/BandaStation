import '../../styles/bandastation/donor_jobs.scss';

import { Icon } from 'tgui-core/components';

export function JobHudIcon(props: { icon?: string; fallback?: string | null }) {
  if (props.icon) {
    return (
      <img
        className="DonorJobs__HudIcon"
        src={`data:image/png;base64,${props.icon}`}
        alt=""
      />
    );
  }
  return props.fallback ? <Icon name={props.fallback} /> : null;
}
