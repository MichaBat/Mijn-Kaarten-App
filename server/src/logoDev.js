const LOGO_DEV_SEARCH_URL = 'https://api.logo.dev/v2/search';

async function searchBrands(query) {
  const url = new URL(LOGO_DEV_SEARCH_URL);
  url.searchParams.set('q', query);
  url.searchParams.set('limit', '10');
  url.searchParams.set('method', 'typeahead');

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${process.env.LOGO_DEV_SECRET_KEY}`,
    },
  });

  if (!response.ok) {
    const error = new Error(`Logo.dev search failed with status ${response.status}`);
    error.status = response.status;
    throw error;
  }

  const body = await response.json();
  return body.data;
}

module.exports = { searchBrands };
