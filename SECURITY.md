# Security Guidelines

## API Key Management

### ⚠️ Important Notice

The `.env` file contains sensitive information and should **never** be committed to version control. Use `.env.example` as a template.

### Current Status

- ✅ `.env` is listed in `.gitignore`
- ✅ `.env.example` template is committed
- ✅ No secrets are tracked in the repository

### API Key Rotation Procedure

If you suspect an API key has been compromised:

#### 1. Revoke the Leaked Key

**Volcengine (火山云):**
1. Log in to [Volcengine Console](https://console.volcengine.com/)
2. Navigate to API Keys management
3. Find the leaked key: `f232da47-2894-4b49-a8b9-94bff9c8e6dd`
4. Delete/Disable it immediately

#### 2. Generate a New API Key

1. Create a new API key in the console
2. Copy the new key securely (do not share)
3. Add it to your local `.env` file:

```bash
VOLCENGINE_API_KEY=your_new_api_key_here
```

#### 3. Verify Configuration

Run the application and test AI functionality:

```bash
flutter run
```

Navigate to the AI Analysis tab and verify the service works.

### Deployment Checklist

Before deploying to production:

- [ ] `.env` file is NOT in git
- [ ] `.env.example` is committed
- [ ] `.gitignore` contains `.env`
- [ ] API keys are valid and active
- [ ] Test all API-dependent features
- [ ] Review commit history for accidentally committed secrets

### Environment Variables

| Variable | Required | Description |
|----------|-----------|-------------|
| `VOLCENGINE_API_KEY` | Yes | Volcengine API authentication key |
| `VOLCENGINE_ENDPOINT` | No | API endpoint URL (default: Volcengine) |
| `VOLCENGINE_MODEL` | No | AI model name (default: deepseek-v3) |
| `AI_ENGINE` | No | AI provider: `volcengine` or `dify` |
| `DIFY_API_KEY` | No | Dify API key (optional) |
| `DIFY_BASE_URL` | No | Dify API URL (optional) |
| `DIFY_APP_ID` | No | Dify application ID (optional) |

### Best Practices

1. **Never commit `.env`** - Always use `.gitignore`
2. **Rotate keys regularly** - Every 3-6 months
3. **Use environment-specific configs** - Separate dev/stage/prod keys
4. **Monitor usage** - Set up alerts for unusual activity
5. **Document key locations** - Keep track of where keys are stored
6. **Use secrets management** - For production, consider:
   - CI/CD environment variables
   - Cloud secret managers (AWS Secrets Manager, etc.)
   - Encrypted config files

### Local Development Setup

1. Copy the template:
```bash
cp .env.example .env
```

2. Edit `.env` with your actual credentials:
```bash
nano .env
```

3. The `.env` file is automatically loaded by `flutter_dotenv`

### CI/CD Integration

For automated deployments, use environment variables:

**GitHub Actions:**
```yaml
env:
  VOLCENGINE_API_KEY: ${{ secrets.VOLCENGINE_API_KEY }}
```

**GitLab CI:**
```yaml
variables:
  VOLCENGINE_API_KEY: $VOLCENGINE_API_KEY
```

### Incident Response

If an API key is accidentally committed:

1. **Immediate Actions**
   - Revoke the key immediately
   - Force remove from git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
   - Push with force (careful!)

2. **Review Access Logs**
   - Check API usage during exposure period
   - Identify any unauthorized access

3. **Notify Users**
   - If user data may be affected
   - Provide clear remediation steps

### Support

For security issues or questions:
- Check the [Volcengine Security Documentation](https://www.volcengine.com/docs/)
- Review [Flutter security best practices](https://flutter.dev/docs/security)

---

Last updated: 2026-02-09
