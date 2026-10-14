import { expect, test } from 'bun:test';
import Juke from './index.js';

test('exec waits for complete stdout and stderr before returning the exit code', async () => {
  const count = 65536;
  const child = `const fs = require('node:fs');
fs.writeSync(1, 'a'.repeat(${count}));
fs.writeSync(2, 'b'.repeat(${count}));
process.exit(7);`;
  const result = await Juke.exec(process.execPath, ['-e', child], {
    silent: true,
    throw: false,
  });
  expect(result.code).toBe(7);
  expect(result.stdout).toBe('a'.repeat(count));
  expect(result.stderr).toBe('b'.repeat(count));
  expect(result.combined.length).toBe(count * 2);
});
