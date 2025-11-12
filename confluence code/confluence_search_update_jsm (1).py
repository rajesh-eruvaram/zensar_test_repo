import os
import requests

JIRA_URL = os.getenv("JIRA_URL")
JIRA_USER = os.getenv("JIRA_USER")
JIRA_TOKEN = os.getenv("JIRA_TOKEN")
CONFLUENCE_URL = os.getenv("CONFLUENCE_URL")
CONFLUENCE_USER = os.getenv("CONFLUENCE_USER")
CONFLUENCE_TOKEN = os.getenv("CONFLUENCE_TOKEN")
ISSUE_KEY = os.getenv("ISSUE_KEY")
FIELD_ID = os.getenv("FIELD_ID", "customfield_10461")
SPACE_KEY = os.getenv("SPACE_KEY", "DBS")

auth_confluence = (CONFLUENCE_USER, CONFLUENCE_TOKEN)
auth_jira = (JIRA_USER, JIRA_TOKEN)

print(f"🔎 Searching Confluence for pages containing {ISSUE_KEY}...")

cql_query = f"(title~\"{ISSUE_KEY}\" OR text~\"{ISSUE_KEY}\")"
url = f"{CONFLUENCE_URL}/rest/api/content/search?cql={requests.utils.quote(cql_query)}&expand=body.storage"

response = requests.get(url, auth=auth_confluence)
response.raise_for_status()

results = response.json().get("results", [])
print(f"✅ Found {len(results)} matching pages")

# Build a list of markdown-style links
links = []
for r in results:
    title = r.get("title")
    link = f"{CONFLUENCE_URL}{r['_links']['webui']}"
    links.append(f"- [{title}]({link})")

if not links:
    print("⚠️ No Confluence pages found containing the key.")
    exit(0)

links_text = "\n".join(links)

# Build the ADF (Atlassian Document Format) content for the field
jira_payload = {
    "fields": {
        FIELD_ID: {
            "type": "doc",
            "version": 1,
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {"type": "text", "text": "Linked Confluence pages:"},
                    ],
                },
                *[
                    {
                        "type": "paragraph",
                        "content": [
                            {
                                "type": "text",
                                "text": f"{title}",
                                "marks": [{"type": "link", "attrs": {"href": f"{CONFLUENCE_URL}{r['_links']['webui']}"}}],
                            }
                        ],
                    }
                    for r in results
                ],
            ],
        }
    }
}

print(f"📝 Updating Jira issue {ISSUE_KEY}...")
jira_api = f"{JIRA_URL}/rest/api/3/issue/{ISSUE_KEY}"
update_resp = requests.put(jira_api, json=jira_payload, auth=auth_jira, headers={"Content-Type": "application/json"})

if update_resp.status_code in [200, 204]:
    print(f"✅ Successfully updated {ISSUE_KEY} with {len(results)} page link(s)")
else:
    print(f"❌ Failed to update Jira: {update_resp.status_code} {update_resp.text}")
