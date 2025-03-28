import { get_tidy_main_webgl_report } from './index.js'

test('Open and parse webgl test page', async () => {
    const report = await get_tidy_main_webgl_report();
    expect(report['Context Name']).toContain('webgl');
    // matches any substring "Vivante"
    expect(report['Unmasked Renderer'][0]).toEqual(expect.stringContaining('Vivante'));
}, 100000);
