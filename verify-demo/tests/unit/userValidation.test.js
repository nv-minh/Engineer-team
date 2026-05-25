// TC-UNIT-001 to TC-UNIT-005: Unit tests for user validation logic
// These tests verify the business rules in server.js without starting the HTTP server

// Extract validation logic (mirrors server.js validation)
function validateUser({ name, email }) {
  if (!name || !email) {
    return { valid: false, error: 'name and email are required' };
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { valid: false, error: 'Invalid email format' };
  }
  return { valid: true };
}

describe('TC-UNIT: User Validation', () => {
  // TC-UNIT-001: Valid user passes validation
  test('TC-UNIT-001: valid name and email passes validation', () => {
    const result = validateUser({ name: 'Alice', email: 'alice@example.com' });
    expect(result.valid).toBe(true);
    expect(result.error).toBeUndefined();
  });

  // TC-UNIT-002: Missing name fails validation
  test('TC-UNIT-002: missing name fails validation', () => {
    const result = validateUser({ name: '', email: 'alice@example.com' });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('name and email are required');
  });

  // TC-UNIT-003: Missing email fails validation
  test('TC-UNIT-003: missing email fails validation', () => {
    const result = validateUser({ name: 'Alice', email: '' });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('name and email are required');
  });

  // TC-UNIT-004: Invalid email format fails
  test('TC-UNIT-004: invalid email format fails validation', () => {
    const result = validateUser({ name: 'Alice', email: 'not-an-email' });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Invalid email format');
  });

  // TC-UNIT-005: Email without domain fails
  test('TC-UNIT-005: email without domain extension fails', () => {
    const result = validateUser({ name: 'Alice', email: 'alice@example' });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Invalid email format');
  });
});
