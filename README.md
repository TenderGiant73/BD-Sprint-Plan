# План главы 1 — сайт для команды

Страница только для просмотра. План редактирует Дима на странице в claude.ai, сюда выкладывается свежая выгрузка.

## Первый запуск (один раз)

1. Создай на GitHub новый репозиторий, например `bullets-deal-plan`.
   - Публичный репозиторий: Pages бесплатно, но страницу сможет открыть любой, у кого есть ссылка.
   - Приватный репозиторий: для Pages нужен платный план GitHub (Pro / Team), и сам сайт всё равно будет доступен по ссылке.
2. Положи в репозиторий содержимое этой папки (`index.html`, `.nojekyll`, `README.md`) и запушь:

   ```bash
   cd plan-site
   git init
   git add .
   git commit -m "План главы 1"
   git branch -M main
   git remote add origin git@github.com:<аккаунт>/bullets-deal-plan.git
   git push -u origin main
   ```

3. На GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch**, ветка `main`, папка `/ (root)` → **Save**.
4. Через 1–2 минуты сайт будет по адресу `https://<аккаунт>.github.io/bullets-deal-plan/`. Эту ссылку и кидаешь команде.

## Как обновлять

1. Пишешь Claude «выгрузи план на сайт». Он обновит `index.html` в этой папке.
2. Пушишь:

   ```bash
   cd plan-site
   git add index.html
   git commit -m "План: обновление"
   git push
   ```

Ссылка не меняется. Если команда видит старую версию, им нужно обновить страницу (Cmd+Shift+R).
