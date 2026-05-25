// TC-INT-001 to TC-INT-006: Integration tests for /users API endpoints
const request = require('supertest');
const app = require('../../server');

beforeEach(async () => {
  // Reset user store between tests
  await request(app).delete('/users');
});

describe('TC-INT: GET /users', () => {
  // TC-INT-001: Empty list initially
  test('TC-INT-001: returns empty array when no users exist', async () => {
    const res = await request(app).get('/users');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  // TC-INT-002: Returns created users
  test('TC-INT-002: returns list of created users', async () => {
    await request(app)
      .post('/users')
      .send({ name: 'Alice', email: 'alice@example.com' });

    const res = await request(app).get('/users');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0]).toMatchObject({ name: 'Alice', email: 'alice@example.com' });
  });
});

describe('TC-INT: POST /users', () => {
  // TC-INT-003: Create user successfully returns 201
  test('TC-INT-003: creates user with valid data, returns 201', async () => {
    const res = await request(app)
      .post('/users')
      .send({ name: 'Bob', email: 'bob@example.com' });

    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({
      id: expect.any(Number),
      name: 'Bob',
      email: 'bob@example.com',
      createdAt: expect.any(String)
    });
  });

  // TC-INT-004: Missing fields returns 400
  test('TC-INT-004: returns 400 when name is missing', async () => {
    const res = await request(app)
      .post('/users')
      .send({ email: 'bob@example.com' });

    expect(res.status).toBe(400);
    expect(res.body.error).toBe('name and email are required');
  });

  // TC-INT-005: Duplicate email returns 409
  test('TC-INT-005: returns 409 for duplicate email', async () => {
    await request(app)
      .post('/users')
      .send({ name: 'Alice', email: 'alice@example.com' });

    const res = await request(app)
      .post('/users')
      .send({ name: 'Alice 2', email: 'alice@example.com' });

    expect(res.status).toBe(409);
    expect(res.body.error).toBe('email already exists');
  });
});

describe('TC-INT: GET /users/:id', () => {
  // TC-INT-006: 404 for unknown user
  test('TC-INT-006: returns 404 for unknown user id', async () => {
    const res = await request(app).get('/users/9999');
    expect(res.status).toBe(404);
    expect(res.body.error).toBe('User not found');
  });
});
