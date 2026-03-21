# Backstage Testing & Verification Guide

**Date**: 2026-03-08  
**Status**: TechDocs infrastructure ready, manual browser testing required

---

## Changes Implemented

### 1. TechDocs Volume Mount Configuration

**Problem**: TechDocs annotation `backstage.io/techdocs-ref: dir:.` was relative to catalog file location, but `mkdocs.yml` and `docs/` were not accessible in container.

**Solution**: Added volume mounts to `backstage/docker-compose.yml`:

```yaml
volumes:
  - /home/sidhant/homelab:/repo:ro  # Repository root for TechDocs
  - /var/run/docker.sock:/var/run/docker.sock  # Docker socket for mkdocs generator
```

**Updated TechDocs References** in `backstage/catalog/all.yaml`:
- Changed `backstage.io/techdocs-ref: dir:.` → `dir:/repo`
- Applies to: `homelab` System and `homelab-operations-hub` Component

**Verification**:
```bash
docker exec backstage ls -la /repo/mkdocs.yml  # ✅ File exists
docker exec backstage ls -la /repo/docs/       # ✅ Directory accessible
```

### 2. Backstage Deployment Status

**Container Status**:
```
backstage            Up 4 minutes
backstage-postgres   Up 4 minutes (healthy)
```

**Logs Confirm**:
- ✅ TechDocs plugin initialized (`Creating Local publisher for TechDocs`)
- ✅ Search indexer registered (`search_index_techdocs` task scheduled every 10 minutes)
- ✅ Catalog loaded without errors
- ✅ No errors in logs (warnings about kubernetes/events backend are expected)

---

## Manual Browser Testing Required

The following features require **browser access** to test properly (web UI + JavaScript rendering):

### Test 1: TechDocs Rendering

**What to Test**: Verify MkDocs documentation renders in the Docs tab

**Steps**:
1. Navigate to: `https://backstage.homelabdev.space/catalog/default/system/homelab`
2. Click the **"Docs"** tab
3. Verify you see:
   - ✅ Left sidebar with navigation (Home, Operations, Backstage, Week Planning sections)
   - ✅ Rendered markdown content from `docs/index.md`
   - ✅ Links work (e.g., click "Runbook" in sidebar → shows `homelab-operations-runbook.md`)

**Expected Behavior**:
- First access triggers TechDocs build (may take 10-30 seconds)
- MkDocs generator runs in Docker (check logs: `docker logs backstage | grep mkdocs`)
- Rendered HTML served from `/api/techdocs/static/docs/default/system/homelab/`

**If Docs Tab is Empty**:
- Check logs: `docker logs backstage --tail 100 | grep -i error`
- Verify mkdocs.yml syntax: `docker exec backstage cat /repo/mkdocs.yml`
- Check TechDocs build logs (will appear in container logs on first access)

**Also Test**:
1. Navigate to: `https://backstage.homelabdev.space/catalog/default/component/homelab-operations-hub`
2. Click **"Docs"** tab
3. Should show same content (both entities reference `/repo`)

---

### Test 2: CI/CD Tab Integration

**What to Test**: Verify GitHub Actions plugin can fetch Gitea workflow runs

**Steps**:
1. Navigate to: `https://backstage.homelabdev.space/catalog/default/component/gitea`
2. Click the **"CI/CD"** tab
3. Check what appears:

**Possible Outcomes**:

#### ✅ Success: Workflow Runs Displayed
- You see recent Gitea Actions workflow runs from `sidhant/homelab` repository
- Status indicators (success/failure), run times, commit info
- This means GitHub Actions plugin successfully authenticated with Gitea API

#### ⚠️ Empty or Error Message
- Tab exists but shows "No CI/CD runs found" or error
- Likely cause: GitHub integration needs authentication token
- **Fix**: Add to `backstage/app-config.yaml`:
  ```yaml
  integrations:
    github:
      - host: gitea.homelabdev.space
        apiBaseUrl: https://gitea.homelabdev.space/api/v1
        token: ${GITEA_TOKEN}  # Add to .env file
  ```

#### 🔴 Tab Doesn't Exist
- Stock Backstage image may not include GitHub Actions plugin
- Workaround: Use "CI/CD (Gitea Actions)" link in **Links** section (always works)

---

### Test 3: Catalog Quality Verification

**What to Test**: Verify all 13 components maintain 100% scorecard score

**Steps**:
1. Browse to any component (e.g., `https://backstage.homelabdev.space/catalog/default/component/traefik`)
2. Verify **About** card shows:
   - ✅ Owner: `ops-team`
   - ✅ Lifecycle: `production`
   - ✅ System: `homelab`
   - ✅ Annotations: `tier`, `criticality`, `runbook`, `gitea-repo`, `github.com/project-slug`
3. Verify **Links** section includes:
   - ✅ Source Directory
   - ✅ Runbook
   - ✅ CI/CD (Gitea Actions)

**Run Scorecard Script**:
```bash
cd /home/sidhant/homelab
bash scripts/backstage-scorecard.sh docs/backstage-scorecard.md
cat docs/backstage-scorecard.md
```

**Expected Output**: All 13 components score `1.00` (100%)

---

### Test 4: Search Functionality

**What to Test**: Verify catalog and TechDocs content is searchable

**Steps**:
1. Use search bar at top of Backstage UI
2. Search for "gitea" → Should find `gitea` Component
3. Search for "runbook" → Should find TechDocs pages containing "runbook"
4. Verify search results link to correct entities/docs

**Note**: TechDocs search indexer runs every 10 minutes (`search_index_techdocs` task), so docs may not be searchable immediately after first build.

---

## Configuration Summary

### Current Backstage Configuration

**TechDocs Entities** (2):
- `homelab` System → `backstage.io/techdocs-ref: dir:/repo`
- `homelab-operations-hub` Component → `backstage.io/techdocs-ref: dir:/repo`

**GitHub Actions Integration** (13 components):
- All components have `github.com/project-slug: sidhant/homelab` annotation
- Integration configured in `app-config.yaml`:
  ```yaml
  integrations:
    github:
      - host: gitea.homelabdev.space
        apiBaseUrl: https://gitea.homelabdev.space/api/v1
  ```

**Scorecard Dimensions** (10):
1. Owner (`spec.owner`)
2. Lifecycle (`spec.lifecycle`)
3. System (`spec.system`)
4. Tier (`homelab.dev/tier` annotation)
5. Criticality (`homelab.dev/criticality` annotation)
6. Runbook annotation (`homelab.dev/runbook`)
7. Gitea repo annotation (`homelab.dev/gitea-repo`)
8. Source link (title: "Source Directory")
9. Runbook link (title: "Runbook")
10. CI/CD link (title: "CI/CD (Gitea Actions)")

---

## Troubleshooting

### TechDocs Not Rendering

**Check 1: Verify volume mount**
```bash
docker exec backstage test -f /repo/mkdocs.yml && echo "✅ Mounted" || echo "❌ Not mounted"
```

**Check 2: Verify mkdocs.yml syntax**
```bash
docker exec backstage cat /repo/mkdocs.yml
```

**Check 3: Watch logs during first access**
```bash
docker logs backstage -f
# Then access Docs tab in browser
# Look for mkdocs build activity
```

**Check 4: Verify Docker socket**
```bash
docker exec backstage test -S /var/run/docker.sock && echo "✅ Socket accessible" || echo "❌ Socket not accessible"
```

### CI/CD Tab Empty

**Option 1: Add Authentication Token**

Generate Gitea token:
```bash
docker exec --user git gitea gitea admin user generate-access-token \
  --username sidhant \
  --token-name backstage-cicd \
  --scopes "read:repository,read:organization" \
  --raw
```

Add to `backstage/.env`:
```
GITEA_TOKEN=<generated-token>
```

Update `backstage/app-config.yaml`:
```yaml
integrations:
  github:
    - host: gitea.homelabdev.space
      apiBaseUrl: https://gitea.homelabdev.space/api/v1
      token: ${GITEA_TOKEN}
```

Restart:
```bash
cd /home/sidhant/backstage && docker-compose restart backstage
```

**Option 2: Use Links Section**

If CI/CD tab doesn't work, users can always click "CI/CD (Gitea Actions)" link in the Links section, which opens Gitea Actions directly.

### Catalog Not Syncing

**Sync catalog manually**:
```bash
cp -r /home/sidhant/homelab/backstage/catalog /home/sidhant/backstage/
docker exec backstage ls -la /app/catalog/all.yaml
```

**Force catalog refresh** (in Backstage UI):
- Navigate to component
- Click "..." menu → "Refresh"

---

## Next Steps Based on Roadie 2025 Report

### ✅ Already Implemented (Advanced Maturity)

1. **Catalog Quality System**:
   - 100% scorecard quality (13/13 components at 1.00)
   - Automated quality gates in CI
   - Policy enforcement (production services ≥ 0.80)

2. **Governance**:
   - Custom annotations for operational metadata
   - CI/CD quality gates
   - Scorecard validation

3. **Documentation Integration**:
   - TechDocs enabled for system + operations hub
   - MkDocs configuration with navigation

4. **Ownership**:
   - All components have clear ownership (`ops-team`)

### 🟡 Recommended Enhancements (Align with "Automation as Control Plane")

1. **Expand Template Ecosystem** (Week 3):
   - Template for adding new monitoring dashboards
   - Template for creating runbooks
   - Template for onboarding existing services to catalog

2. **Integrate Templates with Gitea Actions**:
   - Template triggers Gitea workflow to scaffold repo
   - Automated PR creation for new service catalog entries
   - CI runs preflight checks on template outputs

3. **Add Service Health Widgets** (Week 3-4):
   - Custom homepage showing at-risk services
   - Failing pipeline indicators (once CI/CD tab works)
   - Stale ownership warnings

4. **Expand TechDocs Coverage**:
   - Add `backstage.io/techdocs-ref` to individual components
   - Create component-specific troubleshooting guides
   - Add architecture diagrams

5. **Search & Discovery**:
   - Tag components by domain (`auth`, `cicd`, `observability`)
   - Add `backstage.io/tags` to all components
   - Enable better filtering in catalog

---

## Commands for Next Session

**Check Backstage Health**:
```bash
docker ps | grep backstage
docker logs backstage --tail 50
```

**Verify TechDocs Mount**:
```bash
docker exec backstage ls -la /repo/mkdocs.yml
docker exec backstage ls -la /repo/docs/
```

**Run Scorecard**:
```bash
bash scripts/backstage-scorecard.sh docs/backstage-scorecard.md
```

**Sync Catalog**:
```bash
cp -r /home/sidhant/homelab/backstage/catalog /home/sidhant/backstage/
```

**Restart Backstage**:
```bash
cd /home/sidhant/backstage && docker-compose restart backstage
```

---

## Testing Checklist

- [ ] TechDocs renders for `homelab` System
- [ ] TechDocs renders for `homelab-operations-hub` Component
- [ ] TechDocs navigation works (sidebar links)
- [ ] CI/CD tab shows Gitea workflow runs (or documents why it doesn't)
- [ ] All 13 components maintain 1.00 scorecard score
- [ ] Search finds catalog entities
- [ ] Search finds TechDocs content (after indexer runs)
- [ ] Links section works on all components
- [ ] About card shows all metadata

---

**Next Agent**: Please perform manual browser testing and update this document with actual results.
