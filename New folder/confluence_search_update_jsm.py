import requests, os, json

jira_url = os.getenv("JIRA_URL")
confluence_url = os.getenv("CONFLUENCE_URL")
jira_user = os.getenv("JIRA_USER")
jira_token = os.getenv("JIRA_TOKEN")
issue_key = os.getenv("ISSUE_KEY")
field_id = os.getenv("FIELD_ID")

def fetch_all_pages(space_key="DBS", limit=50):
    """Retrieve all pages from given Confluence space"""
    start = 0
    pages = []
    while True:
        url = f"{confluence_url}/rest/api/content"
        params = {"spaceKey": space_key, "type": "page", "limit": limit, "start": start}
        resp = requests.get(url, params=params, auth=(jira_user, jira_token))
        data = resp.json()
        results = data.get("results", [])
        if not results:
            break
        pages.extend(results)
        if len(results) < limit:
            break
        start += limit
    return pages

def get_page_body(page_id):
    """Retrieve the storage (HTML) body of a page"""
    url = f"{confluence_url}/rest/api/content/{page_id}?expand=body.storage"
    resp = requests.get(url, auth=(jira_user, jira_token))
    if resp.status_code == 200:
        return resp.json().get("body", {}).get("storage", {}).get("value", "")
    return ""

# --- Step 1: Search all Confluence pages ---
print(f"🔍 Scanning all Confluence pages for {issue_key}")
all_pages = fetch_all_pages("DBS")

matches = []
for p in all_pages:
    body = get_page_body(p["id"])
    if issue_key.lower() in body.lower():
        matches.append(p)

if not matches:
    print(f"❌ No Confluence content found for {issue_key}")
    exit(0)

print(f"✅ Found {len(matches)} matching pages for {issue_key}")

# --- Step 2: Build ADF document ---
content = []
for r in matches:
    title = r.get("title", "Untitled Page")
    href = f"{confluence_url}{r['_links']['webui']}"
    paragraph = {
        "type": "paragraph",
        "content": [
            {"type": "text", "text": "• "},
            {
                "type": "text",
                "text": title,
                "marks": [{"type": "link", "attrs": {"href": href}}],
            },
        ],
    }
    content.append(paragraph)

adf_doc = {"type": "doc", "version": 1, "content": content}

# --- Step 3: Update JSM field ---
update_url = f"{jira_url}/rest/api/3/issue/{issue_key}"
payload = {"fields": {field_id: adf_doc}}
headers = {"Content-Type": "application/json"}

update = requests.put(update_url, auth=(jira_user, jira_token),
                      headers=headers, data=json.dumps(payload))
if update.status_code == 204:
    print("✅ JSM updated successfully.")
else:
    print(f"⚠️ Failed to update JSM. Status {update.status_code}")
    print(update.text)
