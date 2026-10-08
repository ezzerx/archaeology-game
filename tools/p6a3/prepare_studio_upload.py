"""Prepare Playwright's supported in-memory file upload for Chrome extension mode.

The extension cannot use DOM.setFileInputFiles with a local filesystem path.
This emits a local, ignored browser_run_code_unsafe payload; it neither contacts
Tripo nor submits any paid job. Inspect the uploaded preview/settings before GO.
Usage: python tools/p6a3/prepare_studio_upload.py <approved-reference.jpg>
"""
import base64
import json
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parents[2]
source = pathlib.Path(sys.argv[1]).resolve()
assert source.is_relative_to(root / 'art/source/p6a3/tool-concepts')
assert source.suffix.lower() in ('.jpg', '.png') and source.stat().st_size < 20_000_000
payload = base64.b64encode(source.read_bytes()).decode('ascii')
mime = 'image/jpeg' if source.suffix.lower() == '.jpg' else 'image/png'
code = '''async (page) => {
  const input = await page.locator('input[type=file]').first().elementHandle();
  await input.setInputFiles({name:NAME, mimeType:MIME,
    buffer:Buffer.from(DATA,'base64')}, {timeout:10000});
  return {uploaded:NAME};
}'''.replace('NAME', json.dumps(source.name)).replace('MIME', json.dumps(mime)).replace('DATA', json.dumps(payload))
output = root / 'work/playwright-test' / ('upload-' + source.name + '.js')
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(code, encoding='utf-8')
print(output)
