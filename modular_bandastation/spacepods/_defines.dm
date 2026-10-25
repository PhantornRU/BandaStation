#ifndef SPACEPOD_ENERGY_UNIT
// Paradise high cells store 10,000 units; native high cells store 100,000 joules.
#define SPACEPOD_ENERGY_UNIT (10 JOULES)
#endif

/// Built-in life support: CO2 moles per second, fresh-air litres per second and active power draw.
#define SPACEPOD_CO2_FILTER_RATE 1
#define SPACEPOD_CABIN_AIR_FLOW_RATE 10
#define SPACEPOD_CABIN_OXYGEN_TARGET 20
#define SPACEPOD_LIFE_SUPPORT_POWER (5 WATTS)
