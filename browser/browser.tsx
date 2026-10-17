import { createElement as h } from 'react';
import { createRoot } from 'react-dom/client';
import { JobsPage } from 'tgui/interfaces/PreferencesMenu/CharacterPreferences/JobsPage';
import { JobSelection } from 'tgui/interfaces/JobSelection';
import { ServerPrefs } from 'tgui/interfaces/PreferencesMenu/useServerPrefs';
import { configAtom, gameDataAtom, gameStaticDataAtom, store, suspendedAtom } from 'tgui/events/store';
import { setupGlobalEvents } from 'tgui-core/events';
import { mergeLatejoinDepartments } from 'tgui/bandastation/job_slots_preferences/latejoin';
import { getJobProfileDescription } from 'tgui/bandastation/job_slots_preferences/profileDescription';
import fixture from './data.json';

const root = createRoot(document.getElementById('react-root')!);
const profiles = ['Активный A', 'Выбранный B', null];
let currentData: any;
store.set(configAtom, { title: 'PR11 contracts browser fixture', status: 2, user: { name: 'Synthetic fixture', observer: 0 }, window: { fancy: 1, key: 'jobs-modularity', size: [1110, 820], scale: 1 } });
store.set(suspendedAtom, false);
setupGlobalEvents();
const shell = (child) => h('div', { className: 'PreferencesMenu', style: { width: '1110px', height: '820px', margin: '12px' } }, child);
(window as any).fixture = {
  setPreferences({lockReason=null, profileError=null, activeSlot=1, banned=false, experience=false, days=0, randomized=false, donorEnabled=true, assignedSlot=2, serverPrefsReady=true} = {}) {
    const jobs = structuredClone(fixture.jobs);
    const names = donorEnabled ? ['Assistant', 'Cargo Technician', 'Barber', 'Prisoner', 'Banker'] : ['Assistant', 'Cargo Technician'];
    jobs.jobs = Object.fromEntries(names.map(name => [name,jobs.jobs[name]]));
    jobs.jobs_sorted = names;
    const donor = Object.fromEntries((donorEnabled ? ['Barber','Prisoner','Banker','Cargo Technician'] : ['Cargo Technician']).map(name => [name,structuredClone(fixture.job_variants[name])]));
    if(donorEnabled){
      donor.Barber.lock_reason = lockReason;
      donor.Banker.lock_reason = 'Требуется подписка уровня 5.';
    }
    for(const job of Object.values(donor)) (job as any).icon='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/i9sAAAAASUVORK5CYII=';
    currentData = {
      character_profiles: profiles, active_slot: activeSlot,
      character_preferences: { misc: { joblessrole: 3 } }, overflow_role: 'Assistant',
      job_preferences: [{ job: donorEnabled?'Barber':'Cargo Technician', priority: 3 }],
      pref_job_slots: {Barber:assignedSlot},
      job_character_profiles: Object.fromEntries(names.map(name => [name,{slot:name==='Barber'?2:1, randomized:name==='Barber'&&randomized, error:name==='Barber'?profileError:null, public_title:name==='Barber'?'Стилист B':fixture.job_character_profiles[name]?.public_title??null}])),
      job_variants:donor, job_bans:banned?['Barber']:[],
      job_required_experience:experience?{Barber:{experience_type:'Crew',required_playtime:121}}:{},
      job_days_left:days?{Barber:days}:{},
    };
    store.set(gameStaticDataAtom, {});
    store.set(gameDataAtom,currentData);
    document.documentElement.className='theme-ss220';
    root.render(shell(h(ServerPrefs.Provider,{value:serverPrefsReady?{jobs}:undefined},h(JobsPage))));
  },
  switchBackendSlotWithoutRender(slot) {
    currentData={...currentData,active_slot:slot,edit_slot:slot};
    store.set(gameDataAtom,currentData);
  },
  setLatejoin({unavailableReason=null,editSlot=1,availability=0}={}) {
    currentData={
      departments_static:{
        Cargo:{color:'#bba067',open_slots:99,jobs:{'Cargo Technician':{description:'Описание из static metadata',command:false,jobIcon:'box',open_slots:99},HiddenStaticJob:{description:'HIDDEN STATIC JOB',command:false}}},
        HiddenDepartment:{color:'#fff',jobs:{HiddenOtherJob:{description:'HIDDEN STATIC DEPARTMENT JOB'}}},
      },
      departments:{Cargo:{color:'#bba067',open_slots:'∞',jobs:{'Cargo Technician':{availability,unavailable_reason:unavailableReason,open_slots:'∞',used_slots:1,prioritized:true,public_title:'Доставщик B',character_profile:'Профиль 2: Выбранный B'}}}},
      edit_slot:editSlot,round_duration:'00:15',shuttle_status:null,is_observer:false,disable_jobs_for_non_observers:false,priority:false,
    };
    store.set(gameStaticDataAtom,{});
    store.set(gameDataAtom,currentData);
    document.documentElement.className='theme-ss220';
    root.render(h(JobSelection));
  },
  helpers() {
    const current={Cargo:{jobs:{Visible:{availability:9,unavailable_reason:'dynamic lock',open_slots:'∞',public_title:'dynamic'}}}};
    const metadata={Cargo:{jobs:{Visible:{description:'static',public_title:'old',availability:0,unavailable_reason:null},Hidden:{}}},HiddenDepartment:{jobs:{HiddenOther:{}}}};
    const before=JSON.stringify({current,metadata});
    const merged=mergeLatejoinDepartments(current,metadata);
    const profile = {slot:2,randomized:true,error:null,public_title:'Стилист B'};
    const tooltip = (entry) => getJobProfileDescription({character_profiles:profiles,job_character_profiles:{Barber:entry}} as any,'Barber');
    return {departments:Object.keys(merged),jobs:Object.keys(merged.Cargo.jobs),visible:merged.Cargo.jobs.Visible,unchanged:before===JSON.stringify({current,metadata}),empty:Object.keys(mergeLatejoinDepartments({},metadata)),tooltip:tooltip(profile),ordinaryTooltip:tooltip({...profile,randomized:false,public_title:null}),errorTooltip:tooltip({...profile,error:'Недоступный профиль'}),missingTooltip:tooltip({...profile,slot:3})};
  },
  currentData() { return structuredClone(currentData); },
  resetActions() { (window as any).__acts=[]; },
};
(window as any).fixture.setPreferences();
