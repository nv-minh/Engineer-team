// Page Object Model for the User Manager page
class UsersPage {
  constructor(page) {
    this.page = page;
  }

  async navigate() {
    await this.page.goto('/');
  }

  async fillForm(name, email) {
    await this.page.getByTestId('user-name-input').fill(name);
    await this.page.getByTestId('user-email-input').fill(email);
  }

  async submitForm() {
    await this.page.getByTestId('submit-button').click();
  }

  async getMessage() {
    return this.page.getByTestId('message');
  }

  async getUserList() {
    return this.page.getByTestId('user-list');
  }

  async resetUsers() {
    // Reset server state via API for test isolation
    await this.page.request.delete('/users');
  }
}

module.exports = { UsersPage };
