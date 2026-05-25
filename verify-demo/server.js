const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// In-memory user store
const users = [];
let nextId = 1;

// GET /users — list all users
app.get('/users', (req, res) => {
  res.json(users);
});

// POST /users — create a user
app.post('/users', (req, res) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json({ error: 'name and email are required' });
  }

  // Email format validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: 'Invalid email format' });
  }

  // Duplicate check
  if (users.find(u => u.email === email)) {
    return res.status(409).json({ error: 'email already exists' });
  }

  const user = { id: nextId++, name, email, createdAt: new Date().toISOString() };
  users.push(user);
  res.status(201).json(user);
});

// GET /users/:id — get single user
app.get('/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

// DELETE /users — reset (for test isolation)
app.delete('/users', (req, res) => {
  users.length = 0;
  nextId = 1;
  res.status(204).end();
});

const PORT = process.env.PORT || 3000;

// Export for testing
module.exports = app;

// Start server only when run directly
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`verify-demo server running at http://localhost:${PORT}`);
  });
}
