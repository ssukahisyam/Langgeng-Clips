# Security Policy

## Reporting A Vulnerability

Do not open a public issue for vulnerabilities, exposed secrets, API-key handling bugs, or user-data leaks.

Report security concerns privately to the project maintainer with:

- A clear description of the issue.
- Steps to reproduce or affected files.
- Potential impact.
- Suggested mitigation, if known.

## Scope

Security-sensitive areas include:

- Groq API key validation and storage.
- Video, audio, transcript, and exported media handling.
- Crash reporting, analytics, and PII scrubbing.
- Android storage permissions and MediaStore writes.
- Release signing, CI secrets, and Play Store credentials.

## Maintainer Response

The maintainer should acknowledge valid reports, assess severity, fix privately when needed, and disclose after mitigation when appropriate.
