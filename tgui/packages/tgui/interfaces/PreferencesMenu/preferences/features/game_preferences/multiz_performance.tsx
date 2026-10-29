import { createDropdownInput, type Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Мульти-Z - детализация',
  category: 'Геймплей',
  description: 'Уровень детализации мульти-Z. Влияет на производительность.',
  component: createDropdownInput({
    [-1]: 'Стандартная',
    // BANDASTATION ADDITION START - Imported five-level map.
    4: 'Максимальная',
    3: 'Очень высокая',
    // BANDASTATION ADDITION END - Imported five-level map.
    2: 'Высокая',
    1: 'Средняя',
    0: 'Низкая',
  }),
};
