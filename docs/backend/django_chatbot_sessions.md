# Django chatbot sessions API deploy

Patient app home history needs these endpoints on GCP:

- `GET /api/chatbot/sessions/?limit=20` (JWT patient)
- `GET /api/chatbot/sessions/<session_id>/` (messages)

## Apply on machine with Django_DL write access

```bat
cd /d D:\cdss\Django_DL
git checkout main
git pull

curl -L -o chatbot_sessions.patch https://raw.githubusercontent.com/hyunkyung31/Flutter_patient/cursor/feat-chatbot-connect/docs/backend/django_chatbot_sessions.patch

git am chatbot_sessions.patch
git push origin HEAD:feat/chatbot-sessions-api
```

Then merge to main and on VM:

```bash
cd /path/to/Django_DL
git pull origin main
# no new migration required (uses existing ChatSession/ChatHistory)
sudo systemctl restart gunicorn   # or your process manager

curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/api/chatbot/sessions/
# expect 401 (auth required), not 404
```
