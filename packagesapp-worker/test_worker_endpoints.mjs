// Automated integration test for packagesapp-worker endpoints
const BASE_URL = 'http://localhost:8787';

async function runTests() {
  console.log('--- Starting Cloudflare Worker API Test Suite ---\n');
  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`❌ FAIL: ${message}`);
      failed++;
    }
  }

  // 1. Root discovery
  try {
    const res = await fetch(`${BASE_URL}/`);
    const data = await res.json();
    assert(res.status === 200 && data.status === 'running', 'GET / returns running discovery');
    assert(data.domain === 'techshiner.com', 'Discovery includes techshiner.com domain');
  } catch (err) {
    assert(false, `GET / error: ${err.message}`);
  }

  // 2. Auth Signup
  const testEmail = `test_${Date.now()}@example.com`;
  let userToken = '';
  let userId = '';

  try {
    const res = await fetch(`${BASE_URL}/api/v1/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'password123',
        displayName: 'Test Telecom User',
      }),
    });
    const data = await res.json();
    assert(res.status === 201 && data.success === true, 'POST /api/v1/auth/signup creates new user (201)');
    assert(Boolean(data.token), 'Signup returns JWT token');
    assert(data.user.email === testEmail, 'Signup returns correct user profile');
    userToken = data.token;
    userId = data.user.id;
  } catch (err) {
    assert(false, `Signup error: ${err.message}`);
  }

  // 3. Auth Signup Duplicate Check
  try {
    const res = await fetch(`${BASE_URL}/api/v1/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'password123',
      }),
    });
    const data = await res.json();
    assert(res.status === 409 && data.success === false, 'POST /api/v1/auth/signup rejects duplicate email (409)');
  } catch (err) {
    assert(false, `Signup duplicate error: ${err.message}`);
  }

  // 4. Auth Login Valid & Invalid
  try {
    const badRes = await fetch(`${BASE_URL}/api/v1/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'wrongpassword',
      }),
    });
    assert(badRes.status === 401, 'POST /api/v1/auth/login rejects wrong password (401)');

    const goodRes = await fetch(`${BASE_URL}/api/v1/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'password123',
      }),
    });
    const goodData = await goodRes.json();
    assert(goodRes.status === 200 && goodData.success === true, 'POST /api/v1/auth/login succeeds (200)');
    assert(Boolean(goodData.token), 'Login returns fresh JWT token');
  } catch (err) {
    assert(false, `Login error: ${err.message}`);
  }

  // 5. Google Sign In
  try {
    const googleRes = await fetch(`${BASE_URL}/api/v1/auth/google`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'google_advisor@techshiner.com',
        displayName: 'Google Partner',
        photoUrl: 'https://example.com/avatar.jpg',
      }),
    });
    const googleData = await googleRes.json();
    assert(googleRes.status === 200 && googleData.success === true, 'POST /api/v1/auth/google succeeds (200)');
    assert(googleData.user.authProvider === 'google', 'Google auth user provider is "google"');
    assert(Boolean(googleData.token), 'Google auth returns JWT token');
  } catch (err) {
    assert(false, `Google auth error: ${err.message}`);
  }

  // 6. Auth Me Endpoint
  try {
    const noAuthRes = await fetch(`${BASE_URL}/api/v1/auth/me`);
    assert(noAuthRes.status === 401, 'GET /api/v1/auth/me rejects unauthorized request (401)');

    const authRes = await fetch(`${BASE_URL}/api/v1/auth/me`, {
      headers: { Authorization: `Bearer ${userToken}` },
    });
    const authData = await authRes.json();
    assert(authRes.status === 200 && authData.user.id === userId, 'GET /api/v1/auth/me returns current user profile');
  } catch (err) {
    assert(false, `Auth me error: ${err.message}`);
  }

  // 7. Favourites Add & Get
  try {
    const addRes = await fetch(`${BASE_URL}/api/v1/favourites/jazz_daily_super`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${userToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ networkId: 'jazz' }),
    });
    const addData = await addRes.json();
    assert(addRes.status === 200 && addData.success === true, 'POST /api/v1/favourites/:packageId adds favourite');

    const getRes = await fetch(`${BASE_URL}/api/v1/favourites`, {
      headers: { Authorization: `Bearer ${userToken}` },
    });
    const getData = await getRes.json();
    assert(getRes.status === 200 && getData.count >= 1, 'GET /api/v1/favourites returns user favourites list');
    assert(getData.favouriteIds.includes('jazz_daily_super'), 'Favourites list includes added package ID');
    assert(getData.packages.some(p => p.id === 'jazz_daily_super'), 'Favourites list contains full formatted package');
  } catch (err) {
    assert(false, `Favourites add/get error: ${err.message}`);
  }

  // 8. Favourites Sync
  try {
    const invalidAddRes = await fetch(`${BASE_URL}/api/v1/favourites/non_existent_pkg_123`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${userToken}`,
        'Content-Type': 'application/json',
      },
    });
    assert(invalidAddRes.status === 404, 'POST /api/v1/favourites/:packageId rejects invalid package ID (404)');

    const syncRes = await fetch(`${BASE_URL}/api/v1/favourites/sync`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${userToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        favourites: [
          { packageId: 'jazz_weekly_super_duper', networkId: 'jazz' },
          { packageId: 'zong_weekly_pro', networkId: 'zong' },
          { packageId: 'ignored_invalid_pkg', networkId: 'none' },
        ],
      }),
    });
    const syncData = await syncRes.json();
    assert(syncRes.status === 200 && syncData.count >= 2, 'POST /api/v1/favourites/sync merges multiple favourites');
    assert(syncData.favouriteIds.includes('jazz_weekly_super_duper'), 'Merged list includes synchronized package');
  } catch (err) {
    assert(false, `Favourites sync error: ${err.message}`);
  }

  // 9. Favourites Delete
  try {
    const delRes = await fetch(`${BASE_URL}/api/v1/favourites/jazz_daily_super`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${userToken}` },
    });
    const delData = await delRes.json();
    assert(delRes.status === 200 && delData.success === true, 'DELETE /api/v1/favourites/:packageId removes favourite');

    const getRes = await fetch(`${BASE_URL}/api/v1/favourites`, {
      headers: { Authorization: `Bearer ${userToken}` },
    });
    const getData = await getRes.json();
    assert(!getData.favouriteIds.includes('jazz_daily_super'), 'Deleted package is no longer in favourites list');
  } catch (err) {
    assert(false, `Favourites delete error: ${err.message}`);
  }

  // 10. Contact Endpoint (Techshiner.com)
  try {
    const contactRes = await fetch(`${BASE_URL}/api/v1/contact`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Usman Ghani',
        email: 'usman@techshiner.com',
        subject: 'Telecom API inquiry',
        message: 'Inquiring about bulk Pakistan packages integration.',
        type: 'contact',
      }),
    });
    const contactData = await contactRes.json();
    assert(contactRes.status === 201 && contactData.success === true, 'POST /api/v1/contact records inquiry (201)');
    assert(contactData.feedback.email === 'usman@techshiner.com', 'Contact record contains email');
  } catch (err) {
    assert(false, `Contact error: ${err.message}`);
  }

  // 11. Feedback Endpoint
  try {
    const fbRes = await fetch(`${BASE_URL}/api/v1/feedback`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Fatima',
        email: 'fatima@example.com',
        rating: 5,
        category: 'accuracy',
        message: 'The package codes are 100% accurate, thanks!',
        type: 'feedback',
      }),
    });
    const fbData = await fbRes.json();
    assert(fbRes.status === 201 && fbData.success === true, 'POST /api/v1/feedback records feedback (201)');
    assert(fbData.feedback.rating === 5, 'Feedback record contains rating 5');
  } catch (err) {
    assert(false, `Feedback error: ${err.message}`);
  }

  // 12. AI Advisor Endpoint
  try {
    const aiRes = await fetch(`${BASE_URL}/api/v1/ai/recommend`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'I need a cheap jazz weekly internet package with data under 500 rs',
        network: 'jazz',
      }),
    });
    const aiData = await aiRes.json();
    assert(aiRes.status === 200 && aiData.success === true, 'POST /api/v1/ai/recommend returns 200');
    assert(typeof aiData.answer === 'string' && aiData.answer.length > 10, 'AI advisor generates recommendation answer');
    assert(Array.isArray(aiData.suggestedPackages) && aiData.suggestedPackages.length > 0, 'AI advisor returns matching suggested packages');
    console.log('AI Recommendation Sample Answer:\n', aiData.answer);
  } catch (err) {
    assert(false, `AI advisor error: ${err.message}`);
  }

  console.log(`\n--- Test Results: ${passed} passed, ${failed} failed ---`);
  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
