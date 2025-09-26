import { launch } from "puppeteer"

async function parse_main_webgl_report() {

  const chromiumArgs = [
    "--disable-seccomp-filter-sandbox",
    "--no-sandbox",
    "--enable-features=UseOzonePlatform",
    "--ozone-platform=wayland"
  ];

  const browser = await launch({ headless: false, args: chromiumArgs, executablePath: '/usr/bin/chromium' });
  const page = await browser.newPage();
  await page.goto('https://webglreport.com/?v=1', {
    waitUntil: 'domcontentloaded',
    timeout: 10000000
  });
  const scraped_data = await page.evaluate(() => {

    // get to the tr which is the father tag of the td elements
    const mainOutput = document.querySelector('.main-output');
    const reportDiv = mainOutput.querySelector('.report');
    const table = reportDiv.querySelector('table');
    const tbody = table.querySelector('tbody')
    const rows = tbody.querySelectorAll('tr');
    const data = [];

    // iterate through each tr inside tbody
    for (let i = 0; i < rows.length; i++) {
      const columns = rows[i].querySelectorAll('td');

      const rowData = [];
      // for each column (there's only one, but columns is a NodeList)
      // get the text inside and append to rowData
      for (const column of columns) {
        rowData.push(column.textContent.trim());
      }

      data.push(rowData);
    }
    return data;
  });
  await browser.close();
  return scraped_data;
}

export async function get_tidy_main_webgl_report() {
  const report = await parse_main_webgl_report();
  const info = {};
  info['Context Name'] = report.at(2);
  info['Unmasked Renderer'] = report.at(8);
  return info;
}

get_tidy_main_webgl_report();