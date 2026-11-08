# One-time Super Admin bootstrap

- Setup page: https://first-star-hotel-api.ponprachanban1.workers.dev/setup
- Owner email: firststargroup@inbox.eu
- The setup page sends the password directly to the same-origin Worker over HTTPS. Do not send passwords in chat or commit them to Git.
- Before setup, rotate the Worker secret SETUP_TOKEN in Cloudflare Dashboard: Workers & Pages → first-star-hotel-api → Settings → Variables and Secrets.
- Keep the secret private and enter it only in the setup page.
- The API checks the setup secret and creates only the first staff account. After the first account is created, further setup attempts are rejected.
- After successful bootstrap, remove the SETUP_TOKEN secret from the Worker because initial setup is complete.
- The initial account uses role owner, which is the highest current role in the Worker API.
