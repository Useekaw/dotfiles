---
name: init-vault
description: >
  Schreibt/aktualisiert im aktuellen Repo-Root das lokale CLAUDE.md mit einem
  Abschnitt "Wissensbasis (Obsidian)", der auf den Obsidian-Vault (MCP-Server
  `gateway`, Prefix `obsidian_`) und dessen Konventionen verweist. Nur der Wissensbasis-Verweis —
  keine Codebase-Dokumentation (dafür separat /init nutzen).
  Trigger: /init-vault, "richte Wissensbasis-Kontext ein", "Vault-Anbindung
  ins CLAUDE.md", neues Repo ohne Obsidian-Bezug im CLAUDE.md.
---

Vollständiges Playbook: Obsidian-Vault, Notiz `20 - Playbooks/Claude Code Repo-Init.md`. Bei Widerspruch zwischen dieser Datei und der Vault-Notiz gilt die Vault-Notiz (Quelle der Wahrheit) — diese Datei nachziehen.

## Ablauf

1. Lokales `CLAUDE.md` im Repo-Root lesen, falls vorhanden.
2. `mcp__gateway__obsidian_vault_list` ohne Pfad (Root) und für `30 - Projekte/` aufrufen — frisch abfragen, nicht auf altes Wissen verlassen.
3. Aktuellen Repo-Verzeichnisnamen gegen Unterordner von `30 - Projekte/` abgleichen (z.B. `home-assistant-migration` ↔ `Home Assistant Migration/`). Eindeutiger Treffer: Pfad merken. Kein eindeutiger Treffer: nicht raten — User kurz fragen oder Abschnitt ohne Projekt-Link schreiben und das im Chat erwähnen.
4. Folgenden Abschnitt bauen (Platzhalter `<PROJEKT_PFAD>` nur einfügen wenn Treffer aus Schritt 3):

```markdown
## Wissensbasis (Obsidian)

Obsidian-Vault erreichbar über MCP-Server `gateway` (MCP-Gateway, Prefix `obsidian_`, dahinter lokale REST API). Tools: `mcp__gateway__obsidian_vault_read`, `obsidian_vault_write`, `obsidian_vault_patch`, `obsidian_vault_get_document_map`, `obsidian_vault_list`, `obsidian_vault_move`, `obsidian_vault_copy`, `obsidian_vault_delete`, `obsidian_search_query`, `obsidian_search_simple`, `obsidian_tag_list`, `obsidian_active_file_get_path`.

Vault-Struktur/Regeln stehen in der Root-`AGENTS.md` des Vaults — vor Vault-Aktionen dort und in der `AGENTS.md` des Zielordners nachlesen (nicht aus altem Snapshot ableiten, Vault wächst).

<PROJEKT_PFAD: Projektspezifischer Kontext zu diesem Repo: `30 - Projekte/<Name>/`.>

Playbook zu diesem Abschnitt: `20 - Playbooks/Claude Code Repo-Init.md`.
```

5. Falls `CLAUDE.md` existiert und schon einen Abschnitt `## Wissensbasis (Obsidian)` hat: nur diesen Abschnitt ersetzen, restlichen Inhalt unverändert lassen. Falls existiert ohne diesen Abschnitt: Abschnitt anhängen. Falls Datei fehlt: neu anlegen, nur mit diesem Abschnitt.
6. Kurz bestätigen was geschrieben wurde (Datei neu/ergänzt, Projekt-Link gefunden oder nicht).

## Nicht tun

- Keine Codebase-Dokumentation generieren (Aufgabe von `/init`, getrennt).
- Keinen vollständigen Vault-Strukturbaum ins CLAUDE.md kopieren — nur Verweis + Tool-Liste, sonst veraltet es.
- Keinen Projektordner in `30 - Projekte/` selbst anlegen, wenn keiner passt — nur melden.
