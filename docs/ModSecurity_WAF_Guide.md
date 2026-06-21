# Apache ModSecurity & OWASP CRS — Developer Guide

## What Happened to Us

Our Prashna API endpoint stopped working because Apache's **ModSecurity** Web Application Firewall (WAF) blocked requests containing `session_id` as a query parameter. The error was `403 Forbidden` on the OPTIONS preflight and GET requests.

**Root Cause:** OWASP Core Rule Set (CRS) **Rule 943110/943120** — Session Fixation Attack Prevention.

---

## What is ModSecurity?

ModSecurity is an open-source WAF that sits in front of your web server (Apache/Nginx). It inspects every incoming HTTP request and blocks anything that looks like an attack. It uses the **OWASP Core Rule Set (CRS)** — a community-maintained set of ~200+ rules that detect common web attacks.

**Architecture in our case:**
```
Browser → Apache (ModSecurity WAF) → Nginx → Django Backend
                ↑
         Blocks here if rule matches
```

---

## Blocked Parameter Names (Session Fixation — Rules 943110 & 943120)

These rules block any request where a **query parameter name** matches a known session identifier pattern. The check is **case-insensitive**.

| Parameter Name | Framework/Language | Blocked? |
|---|---|---|
| `session_id` | Generic | YES |
| `session-id` | Generic (hyphenated) | YES |
| `sessionid` | Generic (no separator) | YES |
| `_session_id` | Ruby on Rails | YES |
| `jsessionid` | Java / J2EE (Tomcat) | YES |
| `jservsession` | Java Servlet | YES |
| `jwsession` | Java Web Session | YES |
| `aspsessionid` | ASP Classic | YES |
| `asp.net_sessionid` | ASP.NET | YES |
| `phpsessid` | PHP (`PHPSESSID`) | YES |
| `phpsession` | PHP | YES |
| `weblogicsession` | Oracle WebLogic | YES |
| `cfid` | ColdFusion | YES |
| `cftoken` | ColdFusion | YES |
| `cfsid` | ColdFusion | YES |
| `_flask_session` | Python / Flask | YES |
| `connect.sid` | Node.js / Express | YES |
| `laravel_session` | Laravel (PHP) | YES |

### When Does It Trigger?

The block happens when **BOTH** conditions are met:

1. A query parameter name matches the list above
2. **AND** one of:
   - **Rule 943110:** The `Referer` header points to a **different domain** (cross-site request)
   - **Rule 943120:** There is **no `Referer` header** at all

This is why:
- **curl worked** — curl doesn't always send a Referer, but it also doesn't trigger the cross-site check the same way
- **Browser failed** — browser sends `Referer: https://dhara.bheri.in/` which is a different domain than `project.iith.ac.in`, triggering Rule 943110
- **Swagger worked** — same-origin request (swagger is on `project.iith.ac.in` itself)

### Safe Alternatives

These parameter names are **NOT blocked**:

| Safe Name | Notes |
|---|---|
| `sid` | Short, clean |
| `chat_id` | Descriptive |
| `conversation_id` | Descriptive |
| `thread_id` | Descriptive |
| `ref` | Short |
| `token` | Not in session fixation list |
| `ctx` | Short for "context" |

**Rule of thumb:** Avoid any parameter name containing `session` in any form.

---

## Other Common ModSecurity Blocks (CRS Categories)

### 1. SQL Injection (Rules 942xxx)

**What triggers it:** Query parameters or POST body containing SQL-like keywords or patterns.

**Blocked patterns in parameter VALUES (not names):**

| Pattern | Example | Why Blocked |
|---|---|---|
| `SELECT ... FROM` | `query=select name from users` | Looks like SQL query |
| `UNION SELECT` | `query=1 UNION SELECT *` | SQL injection technique |
| `OR 1=1` | `id=1 OR 1=1` | Classic SQLi bypass |
| `DROP TABLE` | `input=DROP TABLE users` | Destructive SQL |
| `' OR '1'='1` | `password=' OR '1'='1` | Auth bypass |
| `; DELETE` | `id=1; DELETE FROM users` | Stacked queries |
| `/* comment */` | `id=1/**/UNION` | SQL comment injection |
| Excessive special chars | `input='''""";;;` | Anomaly detection |

**Common false positives:**
- Search queries containing words like "select", "union", "drop", "delete", "update", "insert", "from", "where"
- Example: User searching for *"select the best option from the list"* gets blocked

**Safe practices:**
- Use POST with JSON body for complex queries (body inspection is less aggressive)
- URL-encode special characters properly
- Avoid SQL keywords in query parameter names

### 2. Cross-Site Scripting / XSS (Rules 941xxx)

**Blocked patterns in values:**

| Pattern | Example | Why Blocked |
|---|---|---|
| `<script>` tags | `input=<script>alert(1)</script>` | XSS attack |
| `javascript:` URLs | `url=javascript:alert(1)` | XSS via URL |
| `onerror=` handlers | `img=<img onerror=alert(1)>` | Event handler XSS |
| `<iframe>` tags | `content=<iframe src=evil>` | Frame injection |
| `document.cookie` | `input=document.cookie` | Cookie theft |
| `<svg onload=` | `input=<svg onload=alert(1)>` | SVG-based XSS |
| Angle brackets `< >` | `template=value<>more` | Sometimes false positive |

**Common false positives:**
- User-generated content with HTML/markdown
- Code snippets in search queries
- Template syntax like `{{variable}}`

### 3. Remote Code Execution / Command Injection (Rules 932xxx)

**Blocked patterns:**

| Pattern | Example | Why Blocked |
|---|---|---|
| `; ls -la` | `file=test; ls -la` | Shell command injection |
| `| cat /etc/passwd` | `input=x | cat /etc/passwd` | Pipe injection |
| Backtick execution | `` input=`whoami` `` | Command substitution |
| `$(command)` | `input=$(id)` | Subshell execution |
| `../../../etc/passwd` | `path=../../../etc/passwd` | Path traversal |

### 4. Protocol Violations (Rules 920xxx)

**Blocked patterns:**

| Issue | Example | Why Blocked |
|---|---|---|
| Missing `Content-Type` | POST without Content-Type header | Protocol violation |
| Invalid HTTP method | `TRACE`, `TRACK` methods | Security risk |
| Non-standard characters in URL | URL with null bytes `%00` | Evasion technique |
| Excessively long URLs | URL > 8192 chars | Buffer overflow risk |
| Multiple encoding | Double URL encoding `%2525` | Evasion technique |

### 5. Request Size Limits (Rules 920xxx)

| Limit | Default | Notes |
|---|---|---|
| URL length | ~8192 chars | Configurable |
| Request body size | ~128KB–13MB | Depends on config |
| Number of arguments | ~255 | Per request |
| Argument name length | ~100 chars | Per parameter |
| Argument value length | ~400–4000 chars | Per parameter |
| Combined argument size | ~64KB | Total of all params |

---

## How to Fix ModSecurity Blocks (For Server Admins)

### Option 1: Whitelist Specific Parameters for Specific Paths (Recommended)

Add to `/etc/apache2/conf.d/modsec-exclusions.conf` or equivalent:

```apache
# Allow 'session_id' parameter on Prashna endpoint
SecRule REQUEST_URI "@beginsWith /samiksha/prashna/" \
    "id:10001,phase:1,pass,nolog,\
    ctl:ruleRemoveTargetById=943110;ARGS:session_id,\
    ctl:ruleRemoveTargetById=943120;ARGS:session_id"
```

### Option 2: Whitelist for Entire Application Path

```apache
# Allow session parameters for all Samiksha/Bheri endpoints
SecRule REQUEST_URI "@rx ^/(samiksha|bheri)/" \
    "id:10002,phase:1,pass,nolog,\
    ctl:ruleRemoveById=943110,\
    ctl:ruleRemoveById=943120"
```

### Option 3: Rename the Parameter (What We Did)

Frontend changed `session_id` → `sid`. Backend needs to accept `sid`.

This avoids the WAF entirely without any server config changes.

---

## Best Practices for Our Team

### For Frontend/App Developers:

1. **Avoid session-related parameter names** in URLs — use short names like `sid`, `ref`, `ctx`
2. **Use POST with JSON body** for sensitive data instead of GET query params
3. **Don't put tokens in URLs** — use `Authorization` header instead
4. **URL-encode special characters** properly in search queries
5. **Keep parameter values short** — avoid extremely long strings in URLs
6. **Avoid SQL keywords** in parameter names (e.g., don't name a param `select`, `order`, `union`)

### For Backend Developers:

1. **Accept alternative parameter names** — e.g., accept both `session_id` and `sid`
2. **Prefer POST for sensitive endpoints** — request bodies are less aggressively filtered
3. **Use headers for session tokens** — `Authorization: Bearer <token>` is never blocked
4. **Document API parameter names** — coordinate with frontend on safe naming

### For Server/DevOps:

1. **Monitor ModSecurity audit logs** — check `/var/log/modsec_audit.log` regularly
2. **Use anomaly scoring mode** — don't block on single rule matches; set threshold to 10+
3. **Tune rules per-endpoint** — whitelist specific parameters, not entire rule categories
4. **Test after CRS updates** — rule updates (even minor ones) can introduce new false positives
5. **Keep exclusions documented** — maintain a list of all custom rule exclusions

---

## Quick Debugging Checklist

When you get an unexpected `403 Forbidden`:

1. **Check the response headers** — look for `server: Apache` (WAF block) vs `server: nginx` (backend error)
2. **Test with curl** — remove parameters one by one to find which one triggers the block
3. **Check ModSecurity audit log** on the server:
   ```bash
   tail -f /var/log/modsec_audit.log | grep -A5 "403"
   ```
4. **Look for the Rule ID** — it tells you exactly which rule blocked the request
5. **Add a targeted exclusion** — don't disable rules globally

---

## References

- [OWASP CRS Rule 943 — Session Fixation](https://github.com/SpiderLabs/owasp-modsecurity-crs/blob/v3.0/master/rules/REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION.conf)
- [OWASP Session Fixation Attack](https://owasp.org/www-community/attacks/Session_fixation)
- [Stripe's Same Issue with session_id](https://github.com/coreruleset/coreruleset/issues/2762)
- [CRS False Positive Troubleshooting](https://infrarunbook.com/article/waf-false-positive-troubleshooting)
- [WAF Rule Tuning Guide](https://www.systemshardening.com/articles/network/waf-rule-tuning/)
