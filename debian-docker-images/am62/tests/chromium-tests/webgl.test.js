import { get_tidy_main_webgl_report } from './index.js'

test('Open and parse webgl test page', async () => {
    const report = await get_tidy_main_webgl_report();
    expect(report['Context Name']).toContain('webgl2');
    expect(report['GL Version']).toContain('WebGL 2.0 (OpenGL ES 3.0 Chromium)');
    expect(report['Unmasked Renderer']).toContain('ANGLE (Imagination Technologies, PowerVR A-Series AXE-1-16M, OpenGL ES 3.1)');
}, 100000);
